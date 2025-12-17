import { exec } from 'child_process'
import { promisify } from 'util'
import { TestCase, TestResult, StepResult } from './types.js'
import { LogCollector } from './log-collector.js'

const execAsync = promisify(exec)

// Strip ANSI escape codes to reduce log size
function stripAnsi(str: string): string {
  // Matches ANSI escape sequences including:
  // - CSI sequences: ESC [ ... (letter) - includes ? for private modes like [?25h
  // - OSC sequences: ESC ] ... (BEL or ESC \)
  // - Simple escapes: ESC (letter)
  return str.replace(/\x1b\[[0-9;?]*[a-zA-Z]|\x1b\][^\x07]*\x07|\x1b[()][AB012]|\x1b[a-zA-Z]/g, '')
}

export class TestExecutor {
  private workingDir: string
  private totalTests: number = 0
  private currentTest: number = 0
  private logCollector: LogCollector | null = null
  // Note: currentTestId is shared state - LogCollector only works correctly
  // with sequential execution (concurrency=1). Parallel execution will have
  // inaccurate log boundaries.
  private currentTestId: string | null = null

  constructor(workingDir: string = process.cwd(), logCollector?: LogCollector) {
    this.workingDir = workingDir
    this.logCollector = logCollector || null
  }

  // Progress output goes to stderr (visible in console)
  private progress(msg: string): void {
    process.stderr.write(msg + '\n')
  }

  async executeStep(command: string, timeout: number): Promise<StepResult> {
    const startTime = Date.now()
    let stdout = ''
    let stderr = ''
    let exitCode = 0
    let timedOut = false

    // Build environment with TEST_ID for log access
    const env = { ...process.env }
    if (this.currentTestId) {
      env.TEST_ID = this.currentTestId
    }

    // Update log file before each step so test can access current logs
    if (this.logCollector && this.currentTestId) {
      this.logCollector.writeCurrentLogs(this.currentTestId)
    }

    try {
      const result = await execAsync(command, {
        cwd: this.workingDir,
        timeout,
        maxBuffer: 10 * 1024 * 1024, // 10MB buffer
        shell: '/bin/bash',
        env
      })
      stdout = result.stdout
      stderr = result.stderr
    } catch (error: any) {
      stdout = error.stdout || ''
      stderr = error.stderr || error.message || 'Unknown error'
      exitCode = error.code || 1
      timedOut = error.killed === true
    }

    const duration = Date.now() - startTime

    // Strip ANSI escape codes to reduce log size
    stdout = stripAnsi(stdout)
    stderr = stripAnsi(stderr)

    // Add timeout indicator if command was killed
    if (timedOut) {
      stderr = `[TIMEOUT] Command killed after ${timeout / 1000}s\n\n${stderr}`
    }

    return {
      name: '',
      command,
      stdout,
      stderr,
      exitCode,
      duration
    }
  }

  async executeTestCase(testCase: TestCase): Promise<TestResult> {
    const startTime = Date.now()
    const stepResults: StepResult[] = []
    const timestamp = new Date().toISOString().substring(11, 19)

    this.currentTest++
    this.currentTestId = testCase.id
    this.progress(`[${timestamp}] [${this.currentTest}/${this.totalTests}] ${testCase.id}: ${testCase.name}`)

    // Mark test start for log collection
    if (this.logCollector) {
      this.logCollector.markTestStart(testCase.id)
    }

    for (let i = 0; i < testCase.steps.length; i++) {
      const step = testCase.steps[i]
      const stepTimestamp = new Date().toISOString().substring(11, 19)

      this.progress(`  [${stepTimestamp}] Step ${i + 1}/${testCase.steps.length}: ${step.name}`)
      this.progress(`    Command: ${step.command.substring(0, 80)}${step.command.length > 80 ? '...' : ''}`)

      const timeout = step.timeout || testCase.timeout
      const result = await this.executeStep(step.command, timeout)
      result.name = step.name

      stepResults.push(result)

      // Log step result with status indicator (ASCII for CI compatibility)
      const status = result.exitCode === 0 ? '[PASS]' : '[FAIL]'
      const duration = `${(result.duration / 1000).toFixed(1)}s`
      this.progress(`    ${status} Exit: ${result.exitCode} (${duration})`)

      // Show brief error output if failed
      if (result.exitCode !== 0 && result.stderr) {
        const errorPreview = result.stderr.split('\n')[0].substring(0, 100)
        this.progress(`    Error: ${errorPreview}`)
      }
    }

    const totalDuration = Date.now() - startTime

    // Mark test end for log collection
    if (this.logCollector) {
      this.logCollector.markTestEnd(testCase.id)
    }
    this.currentTestId = null

    // Combine all logs
    const logs = stepResults.map(r => {
      return `=== Step: ${r.name} ===
Command: ${r.command}
Exit Code: ${r.exitCode}
Duration: ${r.duration}ms

STDOUT:
${r.stdout || '(empty)'}

STDERR:
${r.stderr || '(empty)'}
`
    }).join('\n' + '='.repeat(50) + '\n')

    return {
      testCase,
      steps: stepResults,
      totalDuration,
      logs
    }
  }

  async executeAll(testCases: TestCase[], concurrency: number = 1): Promise<TestResult[]> {
    const results: TestResult[] = []

    // Set total for progress tracking
    this.totalTests = testCases.length
    this.currentTest = 0

    const startTimestamp = new Date().toISOString().substring(11, 19)
    this.progress(`\n[${startTimestamp}] Starting ${this.totalTests} test(s)...`)
    this.progress('-'.repeat(60))

    if (concurrency === 1) {
      // Sequential execution
      for (const tc of testCases) {
        const result = await this.executeTestCase(tc)
        results.push(result)
      }
    } else {
      // Parallel execution with p-limit
      const pLimit = (await import('p-limit')).default
      const limit = pLimit(concurrency)

      const promises = testCases.map(tc =>
        limit(() => this.executeTestCase(tc))
      )

      const parallelResults = await Promise.all(promises)
      results.push(...parallelResults)
    }

    // Summary
    const endTimestamp = new Date().toISOString().substring(11, 19)
    this.progress('-'.repeat(60))
    this.progress(`[${endTimestamp}] Execution complete: ${results.length} test(s)`)

    return results
  }
}

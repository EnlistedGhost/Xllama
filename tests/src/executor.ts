import { exec } from 'child_process'
import { promisify } from 'util'
import { TestCase, TestResult, StepResult } from './types.js'

const execAsync = promisify(exec)

export class TestExecutor {
  private workingDir: string
  private totalTests: number = 0
  private currentTest: number = 0

  constructor(workingDir: string = process.cwd()) {
    this.workingDir = workingDir
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

    try {
      const result = await execAsync(command, {
        cwd: this.workingDir,
        timeout,
        maxBuffer: 10 * 1024 * 1024, // 10MB buffer
        shell: '/bin/bash'
      })
      stdout = result.stdout
      stderr = result.stderr
    } catch (error: any) {
      stdout = error.stdout || ''
      stderr = error.stderr || error.message || 'Unknown error'
      exitCode = error.code || 1
    }

    const duration = Date.now() - startTime

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
    this.progress(`[${timestamp}] [${this.currentTest}/${this.totalTests}] ${testCase.id}: ${testCase.name}`)

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

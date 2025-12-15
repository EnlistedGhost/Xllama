import { exec } from 'child_process'
import { promisify } from 'util'
import { TestCase, TestResult, StepResult } from './types.js'

const execAsync = promisify(exec)

export class TestExecutor {
  private workingDir: string

  constructor(workingDir: string = process.cwd()) {
    this.workingDir = workingDir
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

    console.log(`  Executing: ${testCase.id} - ${testCase.name}`)

    for (const step of testCase.steps) {
      console.log(`    Step: ${step.name}`)

      const timeout = step.timeout || testCase.timeout
      const result = await this.executeStep(step.command, timeout)
      result.name = step.name

      stepResults.push(result)

      // Log step result
      if (result.exitCode === 0) {
        console.log(`      Exit: ${result.exitCode} (${result.duration}ms)`)
      } else {
        console.log(`      Exit: ${result.exitCode} (FAILED, ${result.duration}ms)`)
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

    return results
  }
}

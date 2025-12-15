// Test case definition
export interface TestStep {
  name: string
  command: string
  timeout?: number
}

export interface TestCase {
  id: string
  name: string
  suite: string
  priority: number
  timeout: number
  dependencies: string[]
  steps: TestStep[]
  criteria: string
}

// Execution results
export interface StepResult {
  name: string
  command: string
  stdout: string
  stderr: string
  exitCode: number
  duration: number
}

export interface TestResult {
  testCase: TestCase
  steps: StepResult[]
  totalDuration: number
  logs: string
}

// LLM judgment
export interface Judgment {
  testId: string
  pass: boolean
  reason: string
}

// Final report
export interface TestReport {
  testId: string
  name: string
  suite: string
  pass: boolean
  reason: string
  duration: number
  logs: string
}

// Runner options
export interface RunnerOptions {
  suite?: string
  id?: string
  workers: number
  dryRun: boolean
  output: 'console' | 'json' | 'junit'
  reportTestlink: boolean
  ollamaUrl: string
  ollamaModel: string
  testlinkUrl: string
  testlinkApiKey: string
}

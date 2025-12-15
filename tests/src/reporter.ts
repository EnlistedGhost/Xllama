import axios from 'axios'
import { TestReport, Judgment, TestResult } from './types.js'

export class Reporter {
  // Console reporter
  static toConsole(reports: TestReport[]): void {
    console.log('\n' + '='.repeat(60))
    console.log('TEST RESULTS')
    console.log('='.repeat(60))

    const passed = reports.filter(r => r.pass)
    const failed = reports.filter(r => !r.pass)

    for (const report of reports) {
      const status = report.pass ? '\x1b[32mPASS\x1b[0m' : '\x1b[31mFAIL\x1b[0m'
      console.log(`[${status}] ${report.testId}: ${report.name}`)
      console.log(`       Reason: ${report.reason}`)
      console.log(`       Duration: ${report.duration}ms`)
    }

    console.log('\n' + '-'.repeat(60))
    console.log(`Total: ${reports.length} | Passed: ${passed.length} | Failed: ${failed.length}`)
    console.log('='.repeat(60))
  }

  // JSON reporter
  static toJSON(reports: TestReport[]): string {
    return JSON.stringify({
      summary: {
        total: reports.length,
        passed: reports.filter(r => r.pass).length,
        failed: reports.filter(r => !r.pass).length,
        timestamp: new Date().toISOString()
      },
      results: reports
    }, null, 2)
  }

  // JUnit XML reporter (for CI/CD integration)
  static toJUnit(reports: TestReport[]): string {
    const escapeXml = (s: string) => s
      .replace(/&/g, '&amp;')
      .replace(/</g, '&lt;')
      .replace(/>/g, '&gt;')
      .replace(/"/g, '&quot;')
      .replace(/'/g, '&apos;')

    const testcases = reports.map(r => {
      if (r.pass) {
        return `    <testcase name="${escapeXml(r.testId)}: ${escapeXml(r.name)}" classname="${r.suite}" time="${r.duration / 1000}"/>`
      } else {
        return `    <testcase name="${escapeXml(r.testId)}: ${escapeXml(r.name)}" classname="${r.suite}" time="${r.duration / 1000}">
      <failure message="${escapeXml(r.reason)}">${escapeXml(r.logs.substring(0, 1000))}</failure>
    </testcase>`
      }
    }).join('\n')

    const failures = reports.filter(r => !r.pass).length
    const time = reports.reduce((sum, r) => sum + r.duration, 0) / 1000

    return `<?xml version="1.0" encoding="UTF-8"?>
<testsuite name="ollama37-tests" tests="${reports.length}" failures="${failures}" time="${time}">
${testcases}
</testsuite>`
  }

  // Combine results and judgments into reports
  static createReports(results: TestResult[], judgments: Judgment[]): TestReport[] {
    const judgmentMap = new Map(judgments.map(j => [j.testId, j]))

    return results.map(result => {
      const judgment = judgmentMap.get(result.testCase.id)

      return {
        testId: result.testCase.id,
        name: result.testCase.name,
        suite: result.testCase.suite,
        pass: judgment?.pass ?? false,
        reason: judgment?.reason ?? 'No judgment',
        duration: result.totalDuration,
        logs: result.logs
      }
    })
  }
}

// TestLink reporter
export class TestLinkReporter {
  private url: string
  private apiKey: string

  constructor(url: string, apiKey: string) {
    this.url = url
    this.apiKey = apiKey
  }

  async reportResults(
    reports: TestReport[],
    planId: string,
    buildId: string
  ): Promise<void> {
    console.log('\nReporting to TestLink...')

    for (const report of reports) {
      try {
        await this.reportTestExecution(report, planId, buildId)
        console.log(`  Reported: ${report.testId}`)
      } catch (error) {
        console.error(`  Failed to report ${report.testId}:`, error)
      }
    }
  }

  private async reportTestExecution(
    report: TestReport,
    planId: string,
    buildId: string
  ): Promise<void> {
    // Extract numeric test case ID from external ID (e.g., "ollama37-8" -> need internal ID)
    // This would need to be mapped from TestLink

    const status = report.pass ? 'p' : 'f' // p=passed, f=failed, b=blocked

    // Note: This uses the TestLink XML-RPC API
    // In practice, you'd use the testlink-mcp or direct API calls
    const payload = {
      devKey: this.apiKey,
      testcaseexternalid: report.testId,
      testplanid: planId,
      buildid: buildId,
      status,
      notes: `${report.reason}\n\nDuration: ${report.duration}ms\n\nLogs:\n${report.logs.substring(0, 4000)}`
    }

    // For now, just log - actual implementation would call TestLink API
    console.log(`    Would report: ${report.testId} = ${status}`)
  }
}

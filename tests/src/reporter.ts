import axios from "axios";
import { TestReport, Judgment, TestResult, TestSummary } from "./types.js";

export class Reporter {
  // Console reporter
  static toConsole(reports: TestReport[]): void {
    console.log("\n" + "=".repeat(60));
    console.log("TEST RESULTS");
    console.log("=".repeat(60));

    const passed = reports.filter((r) => r.pass);
    const failed = reports.filter((r) => !r.pass);

    // Check if we have dual-judge data
    const hasDualJudge = reports.some(
      (r) => r.simplePass !== undefined && r.llmPass !== undefined,
    );

    for (const report of reports) {
      const status = report.pass
        ? "\x1b[32mPASS\x1b[0m"
        : "\x1b[31mFAIL\x1b[0m";
      console.log(`[${status}] ${report.testId}: ${report.name}`);

      // Show separate verdicts in dual-judge mode
      if (
        hasDualJudge &&
        report.simplePass !== undefined &&
        report.llmPass !== undefined
      ) {
        const simpleStatus = report.simplePass
          ? "\x1b[32mPASS\x1b[0m"
          : "\x1b[31mFAIL\x1b[0m";
        const llmStatus = report.llmPass
          ? "\x1b[32mPASS\x1b[0m"
          : "\x1b[31mFAIL\x1b[0m";
        console.log(
          `       Simple: [${simpleStatus}] ${report.simpleReason || ""}`,
        );
        console.log(`       LLM:    [${llmStatus}] ${report.llmReason || ""}`);
      } else {
        console.log(`       Reason: ${report.reason}`);
      }
      console.log(`       Duration: ${report.duration}ms`);
    }

    console.log("\n" + "-".repeat(60));

    // Show separate summaries in dual-judge mode
    if (hasDualJudge) {
      const simplePassed = reports.filter((r) => r.simplePass).length;
      const simpleFailed = reports.filter((r) => !r.simplePass).length;
      const llmPassed = reports.filter((r) => r.llmPass).length;
      const llmFailed = reports.filter((r) => !r.llmPass).length;

      console.log(`Simple:   ${simplePassed} passed, ${simpleFailed} failed`);
      console.log(`LLM:      ${llmPassed} passed, ${llmFailed} failed`);
      console.log(
        `Combined: ${passed.length} passed, ${failed.length} failed, ${reports.length} total`,
      );
    } else {
      console.log(
        `Total: ${reports.length} | Passed: ${passed.length} | Failed: ${failed.length}`,
      );
    }
    console.log("=".repeat(60));
  }

  // JSON reporter
  static toJSON(reports: TestReport[]): string {
    // Check if we have dual-judge data
    const hasDualJudge = reports.some(
      (r) => r.simplePass !== undefined && r.llmPass !== undefined,
    );

    const summary: TestSummary = {
      total: reports.length,
      passed: reports.filter((r) => r.pass).length,
      failed: reports.filter((r) => !r.pass).length,
      timestamp: new Date().toISOString(),
    };

    // Add separate breakdowns in dual-judge mode
    if (hasDualJudge) {
      summary.simple = {
        passed: reports.filter((r) => r.simplePass).length,
        failed: reports.filter((r) => !r.simplePass).length,
      };
      summary.llm = {
        passed: reports.filter((r) => r.llmPass).length,
        failed: reports.filter((r) => !r.llmPass).length,
      };
    }

    return JSON.stringify(
      {
        summary,
        results: reports,
      },
      null,
      2,
    );
  }

  // JUnit XML reporter (for CI/CD integration)
  static toJUnit(reports: TestReport[]): string {
    const escapeXml = (s: string) =>
      s
        .replace(/&/g, "&amp;")
        .replace(/</g, "&lt;")
        .replace(/>/g, "&gt;")
        .replace(/"/g, "&quot;")
        .replace(/'/g, "&apos;");

    const testcases = reports
      .map((r) => {
        if (r.pass) {
          return `    <testcase name="${escapeXml(r.testId)}: ${escapeXml(r.name)}" classname="${r.suite}" time="${r.duration / 1000}"/>`;
        } else {
          return `    <testcase name="${escapeXml(r.testId)}: ${escapeXml(r.name)}" classname="${r.suite}" time="${r.duration / 1000}">
      <failure message="${escapeXml(r.reason)}">${escapeXml(r.logs.substring(0, 1000))}</failure>
    </testcase>`;
        }
      })
      .join("\n");

    const failures = reports.filter((r) => !r.pass).length;
    const time = reports.reduce((sum, r) => sum + r.duration, 0) / 1000;

    return `<?xml version="1.0" encoding="UTF-8"?>
<testsuite name="ollama37-tests" tests="${reports.length}" failures="${failures}" time="${time}">
${testcases}
</testsuite>`;
  }

  // Combine results and judgments into reports
  static createReports(
    results: TestResult[],
    judgments: Judgment[],
    simpleJudgments?: Judgment[],
    llmJudgments?: Judgment[],
  ): TestReport[] {
    const judgmentMap = new Map(judgments.map((j) => [j.testId, j]));
    const simpleMap = simpleJudgments
      ? new Map(simpleJudgments.map((j) => [j.testId, j]))
      : undefined;
    const llmMap = llmJudgments
      ? new Map(llmJudgments.map((j) => [j.testId, j]))
      : undefined;

    return results.map((result) => {
      const judgment = judgmentMap.get(result.testCase.id);
      const simple = simpleMap?.get(result.testCase.id);
      const llm = llmMap?.get(result.testCase.id);

      const report: TestReport = {
        testId: result.testCase.id,
        name: result.testCase.name,
        suite: result.testCase.suite,
        pass: judgment?.pass ?? false,
        reason: judgment?.reason ?? "No judgment",
        duration: result.totalDuration,
        logs: result.logs,
      };

      // Add separate verdicts if available (dual-judge mode)
      if (simple && llm) {
        report.simplePass = simple.pass;
        report.simpleReason = simple.reason;
        report.llmPass = llm.pass;
        report.llmReason = llm.reason;
      }

      return report;
    });
  }
}

// TestLink reporter
export class TestLinkReporter {
  private url: string;
  private apiKey: string;

  constructor(url: string, apiKey: string) {
    this.url = url;
    this.apiKey = apiKey;
  }

  async reportResults(
    reports: TestReport[],
    planId: string,
    buildId: string,
  ): Promise<void> {
    console.log("\nReporting to TestLink...");

    for (const report of reports) {
      try {
        await this.reportTestExecution(report, planId, buildId);
        console.log(`  Reported: ${report.testId}`);
      } catch (error) {
        console.error(`  Failed to report ${report.testId}:`, error);
      }
    }
  }

  private async reportTestExecution(
    report: TestReport,
    planId: string,
    buildId: string,
  ): Promise<void> {
    // Extract numeric test case ID from external ID (e.g., "ollama37-8" -> need internal ID)
    // This would need to be mapped from TestLink

    const status = report.pass ? "p" : "f"; // p=passed, f=failed, b=blocked

    // Note: This uses the TestLink XML-RPC API
    // In practice, you'd use the testlink-mcp or direct API calls
    const payload = {
      devKey: this.apiKey,
      testcaseexternalid: report.testId,
      testplanid: planId,
      buildid: buildId,
      status,
      notes: `${report.reason}\n\nDuration: ${report.duration}ms\n\nLogs:\n${report.logs.substring(0, 4000)}`,
    };

    // For now, just log - actual implementation would call TestLink API
    console.log(`    Would report: ${report.testId} = ${status}`);
  }
}

import axios from "axios";
import { TestResult, Judgment } from "./types.js";

export class LLMJudge {
  private ollamaUrl: string;
  private model: string;
  private batchSize: number;

  constructor(
    ollamaUrl: string = "http://localhost:11434",
    model: string = "gemma3:4b",
  ) {
    this.ollamaUrl = ollamaUrl;
    this.model = model;
    this.batchSize = 5; // Judge 5 tests per LLM call
  }

  private formatDuration(ms: number): string {
    if (ms < 1000) return `${ms}ms`;
    if (ms < 60000) return `${(ms / 1000).toFixed(1)}s`;
    return `${(ms / 60000).toFixed(1)}min`;
  }

  private buildPrompt(results: TestResult[]): string {
    const testsSection = results
      .map((r, i) => {
        // Build step results summary with exit codes and durations
        const stepsSummary = r.steps
          .map((step, j) => {
            const status = step.exitCode === 0 ? "PASS" : "FAIL";
            const stepTimeout =
              r.testCase.steps[j]?.timeout || r.testCase.timeout;
            return `  ${j + 1}. "${step.name}" - ${status} (exit: ${step.exitCode}, duration: ${this.formatDuration(step.duration)}, timeout: ${this.formatDuration(stepTimeout)})`;
          })
          .join("\n");

        // Simple judge result
        const allStepsPassed = r.steps.every((s) => s.exitCode === 0);
        const simpleResult = allStepsPassed ? "PASS" : "FAIL";

        // Check if duration is within timeout
        const timeoutMs = r.testCase.timeout;
        const withinTimeout = r.totalDuration < timeoutMs;
        const timeoutNote = withinTimeout
          ? `Total duration ${this.formatDuration(r.totalDuration)} is within timeout of ${this.formatDuration(timeoutMs)}.`
          : `Total duration ${this.formatDuration(r.totalDuration)} exceeded timeout of ${this.formatDuration(timeoutMs)}.`;

        return `
### Test ${i + 1}: ${r.testCase.id} - ${r.testCase.name}

**Criteria:**
${r.testCase.criteria}

**Step Results:**
${stepsSummary}

**Simple Judge Result:** ${simpleResult} (${allStepsPassed ? "all steps exit code 0" : "some steps failed"})

**Timing:** ${timeoutNote}
${r.testCase.suite === "build" ? "Note: Long build times are expected for CUDA compilation on older GPUs." : ""}

**Execution Logs:**
\`\`\`
${r.logs.substring(0, 3000)}${r.logs.length > 3000 ? "\n... (truncated)" : ""}
\`\`\`
`;
      })
      .join("\n---\n");

    return `You are a test evaluation judge. Analyze the following test results and determine if each test passed or failed based on the criteria provided.

For each test, examine:
1. The expected criteria
2. The actual execution logs (stdout, stderr, exit codes)
3. Whether the output meets the criteria (use fuzzy matching for AI outputs)

${testsSection}

Respond with a JSON array containing one object per test:
[
  {"testId": "TC-XXX-001", "pass": true, "reason": "Brief explanation"},
  {"testId": "TC-XXX-002", "pass": false, "reason": "Brief explanation"}
]

Important:
- For AI-generated text, accept reasonable variations (e.g., "4", "four", "The answer is 4" are all valid for math questions)
- For build/runtime tests, check exit codes and absence of error messages
- Be lenient with formatting differences, focus on semantic correctness
- If the Simple Judge Result is PASS and duration is within timeout, the test should generally pass unless there are clear errors in the logs
- Long durations are acceptable as long as they are within the configured timeout

Respond ONLY with the JSON array, no other text.`;
  }

  async judgeResults(results: TestResult[]): Promise<Judgment[]> {
    const allJudgments: Judgment[] = [];

    // Process in batches
    for (let i = 0; i < results.length; i += this.batchSize) {
      const batch = results.slice(i, i + this.batchSize);
      // Write progress to stderr to avoid contaminating JSON output on stdout
      process.stderr.write(
        `  Judging batch ${Math.floor(i / this.batchSize) + 1}/${Math.ceil(results.length / this.batchSize)}...\n`,
      );

      try {
        const judgments = await this.judgeBatch(batch);
        allJudgments.push(...judgments);
      } catch (error) {
        console.error(`  Failed to judge batch:`, error);
        // Mark all tests in batch as failed
        for (const r of batch) {
          allJudgments.push({
            testId: r.testCase.id,
            pass: false,
            reason: "LLM judgment failed: " + String(error),
          });
        }
      }
    }

    return allJudgments;
  }

  private async judgeBatch(results: TestResult[]): Promise<Judgment[]> {
    const prompt = this.buildPrompt(results);

    const response = await axios.post(
      `${this.ollamaUrl}/api/generate`,
      {
        model: this.model,
        prompt,
        stream: false,
        options: {
          temperature: 0.1, // Low temperature for consistent judging
          num_predict: 1000,
        },
      },
      {
        timeout: 120000, // 2 minute timeout
      },
    );

    const responseText = response.data.response;

    // Extract JSON from response
    const jsonMatch = responseText.match(/\[[\s\S]*\]/);
    if (!jsonMatch) {
      throw new Error("No JSON array found in LLM response");
    }

    try {
      const judgments = JSON.parse(jsonMatch[0]) as Judgment[];

      // Validate and fill missing
      const resultIds = results.map((r) => r.testCase.id);
      const judgedIds = new Set(judgments.map((j) => j.testId));

      // Add missing judgments
      for (const id of resultIds) {
        if (!judgedIds.has(id)) {
          judgments.push({
            testId: id,
            pass: false,
            reason: "No judgment provided by LLM",
          });
        }
      }

      return judgments;
    } catch (parseError) {
      throw new Error(
        `Failed to parse LLM response: ${responseText.substring(0, 200)}`,
      );
    }
  }

  // Unload the judge model from VRAM to free memory for other tests
  async unloadModel(): Promise<void> {
    try {
      process.stderr.write(
        `  Unloading judge model ${this.model} from VRAM...\n`,
      );
      await axios.post(
        `${this.ollamaUrl}/api/generate`,
        {
          model: this.model,
          keep_alive: 0,
        },
        {
          timeout: 30000,
        },
      );
      process.stderr.write(`  Judge model unloaded.\n`);
    } catch (error) {
      process.stderr.write(
        `  Warning: Failed to unload judge model: ${error}\n`,
      );
    }
  }

  // Fallback: Simple rule-based judgment (no LLM)
  simpleJudge(result: TestResult): Judgment {
    const allStepsPassed = result.steps.every((s) => s.exitCode === 0);

    if (allStepsPassed) {
      return {
        testId: result.testCase.id,
        pass: true,
        reason: "All steps completed with exit code 0",
      };
    } else {
      const failedSteps = result.steps.filter((s) => s.exitCode !== 0);
      return {
        testId: result.testCase.id,
        pass: false,
        reason: `Steps failed: ${failedSteps.map((s) => s.name).join(", ")}`,
      };
    }
  }
}

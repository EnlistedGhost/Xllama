/**
 * LLM Judge - Semantic analysis of test results using Ollama.
 *
 * Uses a language model to evaluate test execution logs against criteria.
 * Catches silent failures that exit code checking misses:
 * - CUDA errors that don't cause exit failures
 * - GPU fallback to CPU mode
 * - Memory allocation warnings
 * - Incorrect but non-crashing output
 */

import axios from 'axios';
import { TestResult, Judgment } from '../types.js';

export class LLMJudge {
  private ollamaUrl: string;
  private model: string;

  constructor(ollamaUrl: string = 'http://localhost:11435', model: string = 'gemma3:12b') {
    this.ollamaUrl = ollamaUrl;
    this.model = model;
  }

  /**
   * Check if the LLM judge is available.
   */
  async isAvailable(): Promise<boolean> {
    try {
      const response = await axios.get(`${this.ollamaUrl}/api/tags`, {
        timeout: 5000,
      });
      return response.status === 200;
    } catch {
      return false;
    }
  }

  /**
   * Format duration for human readability.
   */
  private formatDuration(ms: number): string {
    if (ms < 1000) return `${ms}ms`;
    if (ms < 60000) return `${(ms / 1000).toFixed(1)}s`;
    return `${(ms / 60000).toFixed(1)}min`;
  }

  /**
   * Build prompt for LLM evaluation of a single test.
   */
  private buildPrompt(result: TestResult): string {
    const r = result;
    const stepsSummary = r.steps
      .map((step, j) => {
        const status = step.exitCode === 0 ? 'PASS' : 'FAIL';
        const stepTimeout = r.testCase.steps[j]?.timeout || r.testCase.timeout;
        return `  ${j + 1}. "${step.name}" - ${status} (exit: ${step.exitCode}, duration: ${this.formatDuration(step.duration)}, timeout: ${this.formatDuration(stepTimeout)})`;
      })
      .join('\n');

    const allStepsPassed = r.steps.every((s) => s.exitCode === 0);
    const simpleResult = allStepsPassed ? 'PASS' : 'FAIL';

    const timeoutMs = r.testCase.timeout;
    const withinTimeout = r.totalDuration < timeoutMs;
    const timeoutNote = withinTimeout
      ? `Total duration ${this.formatDuration(r.totalDuration)} is within timeout of ${this.formatDuration(timeoutMs)}.`
      : `Total duration ${this.formatDuration(r.totalDuration)} exceeded timeout of ${this.formatDuration(timeoutMs)}.`;

    // Truncate logs to avoid context overflow
    const logTruncateLimit = 3000;
    const truncatedLogs =
      r.logs.length > logTruncateLimit
        ? r.logs.substring(0, logTruncateLimit) + '\n... (truncated)'
        : r.logs;

    process.stderr.write(`  [LLM] Prompt for ${r.testCase.id}: logs ${r.logs.length} chars (truncated to ${Math.min(r.logs.length, logTruncateLimit)})\n`);

    return `You are a test evaluation judge for ollama37, a build of Ollama for Tesla K80 GPUs (CUDA compute 3.7).

Analyze the following test result and determine if it passed or failed based on the criteria provided.

Examine:
1. The expected criteria
2. The actual execution logs (stdout, stderr, exit codes)
3. Whether the output meets the criteria

K80-specific patterns to watch for:
- "CUBLAS_STATUS_*" errors indicate CUDA issues
- "library=cpu" means GPU detection failed (should be "library=CUDA")
- "compute=3.7" confirms K80 GPU detection (expected)
- "cudaMalloc failed" or "out of memory" indicates VRAM issues

### Test: ${r.testCase.id} - ${r.testCase.name}

**Criteria:**
${r.testCase.criteria}

**Step Results:**
${stepsSummary}

**Simple Judge Result:** ${simpleResult} (${allStepsPassed ? 'all steps exit code 0' : 'some steps failed'})

**Timing:** ${timeoutNote}
${r.testCase.suite === 'build' ? 'Note: Long build times are expected for CUDA compilation on older GPUs.' : ''}

**Execution Logs:**
\`\`\`
${truncatedLogs}
\`\`\`

Respond with a JSON object:
{"testId": "${r.testCase.id}", "pass": true, "reason": "Brief explanation"}

If the test FAILED:
{"testId": "${r.testCase.id}", "pass": false, "reason": "Brief explanation", "evidence": "The actual log line that caused failure"}

Important:
- For AI-generated text, accept reasonable variations (e.g., "4", "four", "The answer is 4")
- For build/runtime tests, check exit codes AND absence of error messages in logs
- If logs show CUDA errors even with exit code 0, the test should FAIL
- Long durations are acceptable if within the configured timeout
- Be lenient with formatting differences, focus on semantic correctness

Respond ONLY with the JSON object, no other text.`;
  }

  /**
   * Judge a single test result.
   */
  private async judgeOne(result: TestResult): Promise<Judgment> {
    const prompt = this.buildPrompt(result);
    const testId = result.testCase.id;

    process.stderr.write(`  [LLM] Prompt size: ${prompt.length} chars\n`);

    const response = await axios.post(
      `${this.ollamaUrl}/api/generate`,
      {
        model: this.model,
        prompt,
        stream: false,
        options: {
          temperature: 0.1,
          num_predict: 1024,
        },
      },
      {
        timeout: 300000,
      }
    );

    const responseText = response.data.response;

    // Log raw response
    if (!responseText) {
      process.stderr.write(`  [LLM] WARNING: Empty response for ${testId}\n`);
      return {
        testId,
        pass: false,
        reason: 'LLM returned empty response',
      };
    }

    process.stderr.write(`  [LLM] Raw response for ${testId} (${responseText.length} chars): ${responseText.substring(0, 500)}\n`);

    // Extract JSON object from response
    const jsonMatch = responseText.match(/\{[\s\S]*\}/);
    if (!jsonMatch) {
      process.stderr.write(`  [LLM] WARNING: No JSON object found in response for ${testId}\n`);
      process.stderr.write(`  [LLM] Full response: ${responseText}\n`);
      return {
        testId,
        pass: false,
        reason: `LLM response contained no JSON: ${responseText.substring(0, 200)}`,
      };
    }

    try {
      const judgment = JSON.parse(jsonMatch[0]) as Judgment;

      // Validate testId matches
      if (judgment.testId !== testId) {
        process.stderr.write(`  [LLM] WARNING: Response testId "${judgment.testId}" doesn't match expected "${testId}"\n`);
        judgment.testId = testId;
      }

      return judgment;
    } catch {
      process.stderr.write(`  [LLM] WARNING: Failed to parse JSON for ${testId}\n`);
      process.stderr.write(`  [LLM] Full response: ${responseText}\n`);
      return {
        testId,
        pass: false,
        reason: `Failed to parse LLM response: ${responseText.substring(0, 200)}`,
      };
    }
  }

  /**
   * Judge all test results, one at a time.
   */
  async judgeResults(results: TestResult[]): Promise<Judgment[]> {
    const allJudgments: Judgment[] = [];

    for (let i = 0; i < results.length; i++) {
      const result = results[i];
      process.stderr.write(
        `  [LLM] Judging ${i + 1}/${results.length}: ${result.testCase.id}...\n`
      );

      try {
        const judgment = await this.judgeOne(result);
        allJudgments.push(judgment);
        process.stderr.write(`  [LLM] ${result.testCase.id}: ${judgment.pass ? 'PASS' : 'FAIL'} — ${judgment.reason}\n`);
      } catch (error) {
        process.stderr.write(`  [LLM] Failed to judge ${result.testCase.id}: ${error}\n`);
        allJudgments.push({
          testId: result.testCase.id,
          pass: false,
          reason: 'LLM judgment failed: ' + String(error),
        });
      }
    }

    return allJudgments;
  }

  /**
   * Unload the judge model from VRAM.
   */
  async unloadModel(): Promise<void> {
    try {
      process.stderr.write(`  [LLM] Unloading judge model ${this.model}...\n`);
      await axios.post(
        `${this.ollamaUrl}/api/generate`,
        {
          model: this.model,
          keep_alive: 0,
        },
        {
          timeout: 30000,
        }
      );
      process.stderr.write(`  [LLM] Judge model unloaded.\n`);
    } catch {
      process.stderr.write(`  [LLM] Warning: Failed to unload judge model\n`);
    }
  }
}

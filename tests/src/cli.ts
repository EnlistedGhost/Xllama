#!/usr/bin/env node

import { Command } from "commander";
import { writeFileSync } from "fs";
import path from "path";
import { fileURLToPath } from "url";
import { TestLoader } from "./loader.js";
import { TestExecutor } from "./executor.js";
import { LLMJudge } from "./judge.js";
import { Reporter, TestLinkReporter } from "./reporter.js";
import { RunnerOptions, Judgment } from "./types.js";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const defaultTestcasesDir = path.join(__dirname, "..", "testcases");

// Progress output to stderr (visible in console even when stdout is redirected)
const log = (msg: string) => process.stderr.write(msg + "\n");

const program = new Command();

program
  .name("ollama37-test")
  .description("Scalable test runner with LLM-as-judge for ollama37")
  .version("1.0.0");

program
  .command("run")
  .description("Run test cases")
  .option(
    "-s, --suite <suite>",
    "Run only tests in specified suite (build, runtime, inference)",
  )
  .option("-i, --id <id>", "Run only specified test case by ID")
  .option("-w, --workers <n>", "Number of parallel workers", "1")
  .option("-d, --dry-run", "Show what would be executed without running")
  .option(
    "-o, --output <format>",
    "Output format: console, json, junit",
    "console",
  )
  .option("--report-testlink", "Report results to TestLink")
  .option(
    "--ollama-url <url>",
    "Ollama server URL (test subject)",
    "http://localhost:11434",
  )
  .option(
    "--judge-url <url>",
    "LLM Judge server URL (separate instance)",
    "http://localhost:11435",
  )
  .option("--judge-model <model>", "Model for LLM judging", "gemma3:4b")
  .option(
    "--testlink-url <url>",
    "TestLink server URL",
    "http://localhost:8090",
  )
  .option("--testlink-api-key <key>", "TestLink API key")
  .option("--no-llm", "Skip LLM judging, use simple exit code check only")
  .option(
    "--dual-judge",
    "Use both simple and LLM judge (fail if either fails)",
  )
  .option("--testcases-dir <dir>", "Test cases directory", defaultTestcasesDir)
  .action(async (options) => {
    log("=".repeat(60));
    log("OLLAMA37 TEST RUNNER");
    log("=".repeat(60));

    const loader = new TestLoader(options.testcasesDir);
    const executor = new TestExecutor(path.join(__dirname, "..", ".."));
    const judge = new LLMJudge(options.judgeUrl, options.judgeModel);

    // Load test cases
    log("\nLoading test cases...");
    let testCases = await loader.loadAll();

    if (options.suite) {
      testCases = testCases.filter((tc) => tc.suite === options.suite);
      log(`  Filtered by suite: ${options.suite}`);
    }

    if (options.id) {
      testCases = testCases.filter((tc) => tc.id === options.id);
      log(`  Filtered by ID: ${options.id}`);
    }

    // Sort by dependencies
    testCases = loader.sortByDependencies(testCases);

    log(`  Found ${testCases.length} test cases`);

    if (testCases.length === 0) {
      log("\nNo test cases found!");
      process.exit(1);
    }

    // Dry run
    if (options.dryRun) {
      log("\nDRY RUN - Would execute:");
      for (const tc of testCases) {
        log(`  ${tc.id}: ${tc.name}`);
        for (const step of tc.steps) {
          log(`    - ${step.name}: ${step.command}`);
        }
      }
      process.exit(0);
    }

    // Execute tests (progress goes to stderr via executor)
    const workers = parseInt(options.workers);
    const results = await executor.executeAll(testCases, workers);

    // Judge results
    log("\nJudging results...");
    let judgments: Judgment[];
    let simpleJudgments: Judgment[] | undefined;
    let llmJudgments: Judgment[] | undefined;

    if (options.dualJudge) {
      // Dual judge mode: run both simple and LLM, fail if either fails
      log("  Using dual judge mode (simple + LLM)");

      // Simple judge first
      simpleJudgments = results.map((r) => judge.simpleJudge(r));
      log("  Simple judge complete");

      // LLM judge second
      try {
        llmJudgments = await judge.judgeResults(results);
        log("  LLM judge complete");
      } catch (error) {
        log(`  LLM judge failed: ${error}`);
        log("  Falling back to simple judge only");
        llmJudgments = simpleJudgments;
      }

      // Combine: fail if either judge says fail
      judgments = simpleJudgments.map((simple, i) => {
        const llm =
          llmJudgments!.find((j) => j.testId === simple.testId) || simple;
        const pass = simple.pass && llm.pass;

        let reason = "";
        if (!pass) {
          const reasons = [];
          if (!simple.pass) reasons.push(`Simple: ${simple.reason}`);
          if (!llm.pass) reasons.push(`LLM: ${llm.reason}`);
          reason = reasons.join(" | ");
        } else {
          reason = llm.reason || simple.reason;
        }

        return {
          testId: simple.testId,
          pass,
          reason,
        };
      });
    } else if (options.llm === false) {
      log("  Using simple exit code check (--no-llm)");
      judgments = results.map((r) => judge.simpleJudge(r));
    } else {
      try {
        judgments = await judge.judgeResults(results);
      } catch (error) {
        log(`  LLM judging failed, falling back to simple check: ${error}`);
        judgments = results.map((r) => judge.simpleJudge(r));
      }
    }

    // Unload judge model from VRAM if LLM was used
    if (options.llm !== false) {
      await judge.unloadModel();
    }

    // Create reports (with separate verdicts in dual-judge mode)
    const reports = Reporter.createReports(
      results,
      judgments,
      simpleJudgments,
      llmJudgments,
    );

    // Output results
    switch (options.output) {
      case "json":
        const json = Reporter.toJSON(reports);
        // JSON goes to stdout (can be redirected to file)
        process.stdout.write(json + "\n");
        break;

      case "junit":
        const junit = Reporter.toJUnit(reports);
        writeFileSync("test-results.xml", junit);
        log("\nResults written to test-results.xml");
        break;

      case "console":
      default:
        Reporter.toConsole(reports);
        break;
    }

    // Summary
    const passed = reports.filter((r) => r.pass).length;
    const failed = reports.filter((r) => !r.pass).length;
    log("\n" + "=".repeat(60));
    log(`SUMMARY: ${passed} passed, ${failed} failed, ${reports.length} total`);
    log("=".repeat(60));

    // Report to TestLink
    if (options.reportTestlink && options.testlinkApiKey) {
      const testlinkReporter = new TestLinkReporter(
        options.testlinkUrl,
        options.testlinkApiKey,
      );
      // Would need plan ID and build ID
      // await testlinkReporter.reportResults(reports, planId, buildId)
      log("\nTestLink reporting not yet implemented");
    }

    // Exit with appropriate code
    process.exit(failed > 0 ? 1 : 0);
  });

program
  .command("list")
  .description("List all test cases")
  .option("--testcases-dir <dir>", "Test cases directory", defaultTestcasesDir)
  .action(async (options) => {
    const loader = new TestLoader(options.testcasesDir);
    const testCases = await loader.loadAll();

    const grouped = loader.groupBySuite(testCases);

    console.log("Available Test Cases:\n");
    for (const [suite, cases] of grouped) {
      console.log(`${suite.toUpperCase()}:`);
      for (const tc of cases) {
        console.log(`  ${tc.id}: ${tc.name}`);
      }
      console.log();
    }

    console.log(`Total: ${testCases.length} test cases`);
  });

program.parse();

#!/usr/bin/env node

import { Command } from 'commander'
import { writeFileSync } from 'fs'
import path from 'path'
import { fileURLToPath } from 'url'
import { TestLoader } from './loader.js'
import { TestExecutor } from './executor.js'
import { LLMJudge } from './judge.js'
import { Reporter, TestLinkReporter } from './reporter.js'
import { RunnerOptions } from './types.js'

const __dirname = path.dirname(fileURLToPath(import.meta.url))
const defaultTestcasesDir = path.join(__dirname, '..', 'testcases')

const program = new Command()

program
  .name('ollama37-test')
  .description('Scalable test runner with LLM-as-judge for ollama37')
  .version('1.0.0')

program
  .command('run')
  .description('Run test cases')
  .option('-s, --suite <suite>', 'Run only tests in specified suite (build, runtime, inference)')
  .option('-i, --id <id>', 'Run only specified test case by ID')
  .option('-w, --workers <n>', 'Number of parallel workers', '1')
  .option('-d, --dry-run', 'Show what would be executed without running')
  .option('-o, --output <format>', 'Output format: console, json, junit', 'console')
  .option('--report-testlink', 'Report results to TestLink')
  .option('--ollama-url <url>', 'Ollama server URL', 'http://localhost:11434')
  .option('--ollama-model <model>', 'Ollama model for judging', 'gemma3:4b')
  .option('--testlink-url <url>', 'TestLink server URL', 'http://localhost:8090')
  .option('--testlink-api-key <key>', 'TestLink API key')
  .option('--no-llm', 'Skip LLM judging, use simple exit code check')
  .option('--testcases-dir <dir>', 'Test cases directory', defaultTestcasesDir)
  .action(async (options) => {
    console.log('='.repeat(60))
    console.log('OLLAMA37 TEST RUNNER')
    console.log('='.repeat(60))

    const loader = new TestLoader(options.testcasesDir)
    const executor = new TestExecutor(path.join(__dirname, '..', '..'))
    const judge = new LLMJudge(options.ollamaUrl, options.ollamaModel)

    // Load test cases
    console.log('\nLoading test cases...')
    let testCases = await loader.loadAll()

    if (options.suite) {
      testCases = testCases.filter(tc => tc.suite === options.suite)
      console.log(`  Filtered by suite: ${options.suite}`)
    }

    if (options.id) {
      testCases = testCases.filter(tc => tc.id === options.id)
      console.log(`  Filtered by ID: ${options.id}`)
    }

    // Sort by dependencies
    testCases = loader.sortByDependencies(testCases)

    console.log(`  Found ${testCases.length} test cases`)

    if (testCases.length === 0) {
      console.log('\nNo test cases found!')
      process.exit(1)
    }

    // Dry run
    if (options.dryRun) {
      console.log('\nDRY RUN - Would execute:')
      for (const tc of testCases) {
        console.log(`  ${tc.id}: ${tc.name}`)
        for (const step of tc.steps) {
          console.log(`    - ${step.name}: ${step.command}`)
        }
      }
      process.exit(0)
    }

    // Execute tests
    console.log('\nExecuting tests...')
    const workers = parseInt(options.workers)
    const results = await executor.executeAll(testCases, workers)

    // Judge results
    console.log('\nJudging results...')
    let judgments
    if (options.llm === false) {
      console.log('  Using simple exit code check (--no-llm)')
      judgments = results.map(r => judge.simpleJudge(r))
    } else {
      try {
        judgments = await judge.judgeResults(results)
      } catch (error) {
        console.error('  LLM judging failed, falling back to simple check:', error)
        judgments = results.map(r => judge.simpleJudge(r))
      }
    }

    // Create reports
    const reports = Reporter.createReports(results, judgments)

    // Output results
    switch (options.output) {
      case 'json':
        const json = Reporter.toJSON(reports)
        console.log(json)
        writeFileSync('test-results.json', json)
        console.log('\nResults written to test-results.json')
        break

      case 'junit':
        const junit = Reporter.toJUnit(reports)
        writeFileSync('test-results.xml', junit)
        console.log('\nResults written to test-results.xml')
        break

      case 'console':
      default:
        Reporter.toConsole(reports)
        break
    }

    // Report to TestLink
    if (options.reportTestlink && options.testlinkApiKey) {
      const testlinkReporter = new TestLinkReporter(
        options.testlinkUrl,
        options.testlinkApiKey
      )
      // Would need plan ID and build ID
      // await testlinkReporter.reportResults(reports, planId, buildId)
      console.log('\nTestLink reporting not yet implemented')
    }

    // Exit with appropriate code
    const failed = reports.filter(r => !r.pass).length
    process.exit(failed > 0 ? 1 : 0)
  })

program
  .command('list')
  .description('List all test cases')
  .option('--testcases-dir <dir>', 'Test cases directory', defaultTestcasesDir)
  .action(async (options) => {
    const loader = new TestLoader(options.testcasesDir)
    const testCases = await loader.loadAll()

    const grouped = loader.groupBySuite(testCases)

    console.log('Available Test Cases:\n')
    for (const [suite, cases] of grouped) {
      console.log(`${suite.toUpperCase()}:`)
      for (const tc of cases) {
        console.log(`  ${tc.id}: ${tc.name}`)
      }
      console.log()
    }

    console.log(`Total: ${testCases.length} test cases`)
  })

program.parse()

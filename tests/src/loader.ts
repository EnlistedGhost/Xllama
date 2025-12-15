import { readFileSync } from 'fs'
import { glob } from 'glob'
import yaml from 'js-yaml'
import path from 'path'
import { TestCase } from './types.js'

export class TestLoader {
  private testcasesDir: string

  constructor(testcasesDir: string = './testcases') {
    this.testcasesDir = testcasesDir
  }

  async loadAll(): Promise<TestCase[]> {
    const pattern = path.join(this.testcasesDir, '**/*.yml')
    const files = await glob(pattern)

    const testCases: TestCase[] = []

    for (const file of files) {
      try {
        const content = readFileSync(file, 'utf-8')
        const testCase = yaml.load(content) as TestCase

        // Set defaults
        testCase.timeout = testCase.timeout || 60000
        testCase.dependencies = testCase.dependencies || []
        testCase.priority = testCase.priority || 1

        testCases.push(testCase)
      } catch (error) {
        console.error(`Failed to load ${file}:`, error)
      }
    }

    return testCases
  }

  async loadBySuite(suite: string): Promise<TestCase[]> {
    const all = await this.loadAll()
    return all.filter(tc => tc.suite === suite)
  }

  async loadById(id: string): Promise<TestCase | undefined> {
    const all = await this.loadAll()
    return all.find(tc => tc.id === id)
  }

  // Sort test cases by dependencies (topological sort)
  sortByDependencies(testCases: TestCase[]): TestCase[] {
    const sorted: TestCase[] = []
    const visited = new Set<string>()
    const idMap = new Map(testCases.map(tc => [tc.id, tc]))

    const visit = (tc: TestCase) => {
      if (visited.has(tc.id)) return
      visited.add(tc.id)

      // Visit dependencies first
      for (const depId of tc.dependencies) {
        const dep = idMap.get(depId)
        if (dep) visit(dep)
      }

      sorted.push(tc)
    }

    // Sort by priority first, then by dependencies
    const byPriority = [...testCases].sort((a, b) => a.priority - b.priority)
    for (const tc of byPriority) {
      visit(tc)
    }

    return sorted
  }

  // Group test cases by suite for parallel execution
  groupBySuite(testCases: TestCase[]): Map<string, TestCase[]> {
    const groups = new Map<string, TestCase[]>()

    for (const tc of testCases) {
      const suite = tc.suite
      if (!groups.has(suite)) {
        groups.set(suite, [])
      }
      groups.get(suite)!.push(tc)
    }

    return groups
  }
}

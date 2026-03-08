Add a test case to the ollama37 test framework. Reference `.claude/skills/add-test.md` for context.

The user will provide: **$ARGUMENTS** (suite name and description of what to test)

## Steps

1. **Identify user story** — Ask the user for the GitHub issue number, or create one if needed.

2. **Determine the suite** — build, runtime, inference, or models.

3. **Find next ID** — Check existing test cases to auto-increment:

```bash
ls cicd/tests/testcases/<suite>/
```

4. **Create TestLink test case** — Use MCP tool to create the test case in TestLink:

```
mcp__testlink__create_test_case:
  project_id: "1"
  suite_id: "<suite ID>"  # Build=2, Inference=3, Runtime=39, Models=122
  name: "TC-<SUITE>-<NNN>: <Descriptive Name>"
  summary: "Related to #<issue>. <What this test validates.>"
  steps: [{ actions: "<command>", expected_results: "<expected>" }]
  importance: 2
  execution_type: 2
```

Record the returned `tc_external_id` as the `testlink_id`.

5. **Create the YAML test case** at `cicd/tests/testcases/<suite>/TC-<SUITE>-<NNN>.yml`:

```yaml
id: TC-<SUITE>-<NNN>
name: <Descriptive Name>
suite: <suite>
priority: <1-3>
timeout: <milliseconds>
dependencies: []
testlink_id: ollama37-<N>
issue: <github-issue-number>

steps:
  - name: <step description>
    command: <bash command>
    expectPatterns:
      - "<regex pattern>"
    rejectPatterns:
      - "<regex pattern>"

criteria: |
  <Description for LLM judge>

  Expected:
  - <condition 1>
  - <condition 2>
```

6. **Verify** — Run the new test:

```bash
cd cicd/tests && npm run test -- --suite <suite>
```

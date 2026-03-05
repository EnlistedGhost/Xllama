Add a test case to the ollama37 test framework. Reference `.claude/skills/add-test.md` for context.

The user will provide: **$ARGUMENTS** (suite name and description of what to test)

## Steps

1. **Determine the suite** — build, runtime, inference, or models.

2. **Find next ID** — Check existing test cases to auto-increment:

```bash
ls cicd/tests/testcases/<suite>/
```

3. **Create the YAML test case** at `cicd/tests/testcases/<suite>/TC-<SUITE>-<NNN>.yml`:

```yaml
id: TC-<SUITE>-<NNN>
name: <Descriptive Name>
suite: <suite>
priority: <1-3>
timeout: <milliseconds>
dependencies: []

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

4. **Add spec entry** — Append the test specification to `cicd/specs/<suite>.md` following the existing format:

```markdown
---

## TC-<SUITE>-<NNN>: <Name>

**Importance:** <High/Medium/Low>
**Execution Type:** Automated
**Timeout:** <seconds> seconds

**Summary:**
<What this test verifies>

### Steps

| # | Action | Expected Result |
|---|--------|-----------------|
| 1 | <command> | <expected output> |
```

5. **Verify** — Run the new test:

```bash
cd cicd/tests && npm run test -- --suite <suite>
```

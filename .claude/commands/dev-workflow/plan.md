# Plan Development Work into GitHub Issues

```
Break down a user request into GitHub Issues with labels and priorities.
Reference `.claude/skills/plan/SKILL.md` for context.

Request: $ARGUMENTS

## PURPOSE

Analyzes a feature request, enhancement, or bug report and creates well-structured
GitHub Issues with proper labels and priorities. Checks for duplicates, breaks down
multi-part requests, and waits for user approval before implementation begins.

---

## WORKFLOW

    /plan Add CUDA kernel for new GGML operation
        │
        ├─► Step 1: Check Existing Issues
        │   - Run: gh issue list --state all --limit 50
        │   - Scan for duplicates or related issues
        │   - If duplicate found, report and ask user how to proceed
        │
        ├─► Step 2: Classify the Request
        │   - Determine type: feature / enhancement / removal / bug
        │   - Determine priority: critical / high / medium / low
        │   - Determine components: ggml / cuda / model / go / ci
        │   - Break down into individual issues if request covers multiple items
        │
        ├─► Step 3: Create Labels (idempotent)
        │   - Ensure type labels exist:
        │     • feature        (color: #0e8a16) — New capability
        │     • enhancement    (color: #1d76db) — Improve existing
        │     • removal        (color: #e4e669) — Remove functionality
        │     • bug            (color: #d93f0b) — Bug report
        │   - Ensure priority labels exist:
        │     • priority:critical (color: #b60205) — Drop everything
        │     • priority:high    (color: #d93f0b) — Important, fix soon
        │     • priority:medium  (color: #fbca04) — Normal priority
        │     • priority:low     (color: #0e8a16) — Nice to have
        │   - Ensure component labels exist:
        │     • component:ggml   (color: #c5def5) — GGML backend
        │     • component:cuda   (color: #c5def5) — CUDA/GPU
        │     • component:model  (color: #c5def5) — Model architecture
        │     • component:go     (color: #c5def5) — Go runtime
        │     • component:ci     (color: #c5def5) — CI/CD pipeline
        │   - Ensure status labels exist:
        │     • status:in-progress  (color: #1d76db) — Work started
        │     • status:needs-review (color: #e4e669) — PR open, awaiting review
        │     • status:blocked      (color: #d93f0b) — Blocked by dependency
        │   - Use: gh label create "<name>" --color "<hex>" --description "<desc>" --force
        │
        ├─► Step 4: Create Issues
        │   - One issue per distinct work item
        │   - Use the appropriate body template (see below)
        │   - Apply type + priority + component labels
        │   - Link related issues: "Depends on #N", "Related to #N"
        │
        ├─► Step 5: Add to Project Board
        │   - Run: gh project item-add 2 --owner dogkeeper886 --url <issue-url>
        │
        ├─► Step 6: Summarize
        │   - Output a table of created issues:
        │     | Issue | Title | Type | Priority | URL |
        │   - Wait for user approval before proceeding
        │
        └─► Step 7: User Approval Gate
            - Ask: "Want me to start on #N?"
            - Do NOT proceed to /implement until user explicitly approves

---

## ISSUE BODY TEMPLATES

### Feature / Enhancement

    ## User Story
    As a [role], I want [capability], so that [benefit].

    ## Acceptance Criteria
    1. ...

    ## Technical Notes
    - ...

    ## Dependencies
    - None | Depends on #N

### Bug

    ## Description
    ...

    ## Expected Behavior
    ...

    ## Steps to Reproduce
    1. ...

---

## EXAMPLE

    /plan Add release notes generator command

**Agent creates:**

    gh issue create \
      --label "feature" --label "priority:medium" \
      --title "Add release notes generator command" \
      --body "## User Story
    As a developer, I want to generate release notes from git history,
    so that I can quickly summarize changes for each release.

    ## Acceptance Criteria
    1. Command reads git log between two tags
    2. Groups commits by type (feature, fix, docs)
    3. Outputs formatted markdown

    ## Dependencies
    - None"

    gh project item-add 2 --owner dogkeeper886 --url <issue-url>

**Output:**

    | Issue | Title                              | Type    | Priority | URL                    |
    |-------|------------------------------------|---------|----------|------------------------|
    | #27   | Add release notes generator command | feature | medium   | https://github.com/... |

    Want me to start on #27?

---

## API Notes

- Uses `gh` CLI — must be authenticated (`gh auth status`)
- Labels use `--force` flag so existing labels are updated, not duplicated
- Always check for duplicates before creating new issues
- The issue body is the single source of truth for the work item
```

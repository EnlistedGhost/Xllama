# Claude Code Custom Slash Command Format

## File Location

```
.claude/commands/<name>.md        ← project scope
~/.claude/commands/<name>.md      ← global scope
```

Filename (without `.md`) becomes the command name.
e.g. `refactor.md` → `/refactor`

---

## Basic (no frontmatter)

```markdown
Refactor the selected code to improve readability and maintainability.
Focus on clean code principles and best practices.
```

---

## With Frontmatter

```markdown
---
allowed-tools: Read, Grep, Glob
description: Run security vulnerability scan
model: claude-opus-4-6
argument-hint: [issue-number] [priority]
---

Fix issue #$1 with priority $2.
Analyze the codebase for security vulnerabilities.
```

---

## Frontmatter Fields

| Field | Description |
|---|---|
| `description` | Shown in autocomplete; helps Claude decide when to auto-load |
| `allowed-tools` | Restrict tools e.g. `Read, Grep, Bash(git diff:*)` |
| `model` | Override model for this command |
| `argument-hint` | Label for expected arguments |
| `context` | Set to `fork` to run in a sub-agent |
| `agent` | Specify sub-agent type e.g. `Explore`, `Plan` |

---

## Arguments

- `$1`, `$2` — positional arguments
- `$ARGUMENTS` — all arguments as a single string

### Example

```markdown
---
argument-hint: [issue-number] [priority]
description: Fix a GitHub issue
---

Fix issue #$1 with priority $2.
Check the issue description and implement the necessary changes.
```

Invoked as: `/fix-issue 123 high`

---

## Dynamic Context

```markdown
- Current diff: !`git diff HEAD`
- Git status: !`git status`
- Config file: @package.json
```

| Syntax | Description |
|---|---|
| `` !`<cmd>` `` | Execute bash command and inject output |
| `@filename` | Inject file content |

### Full Example with Dynamic Context

```markdown
---
allowed-tools: Bash(git add:*), Bash(git status:*), Bash(git commit:*)
description: Create a git commit
---

## Context

- Current status: !`git status`
- Current diff: !`git diff HEAD`

## Task

Create a git commit with appropriate message based on the changes.
```

---

## Subdirectory Namespacing

```
.claude/commands/
├── backend/
│   └── api-test.md     → /api-test
├── frontend/
│   └── component.md    → /component
└── review.md           → /review
```

Subdirectory name appears in description but does **not** affect the command name.

---

## Notes

- Files in `.claude/commands/` still work with the same frontmatter
- Skills (`.claude/skills/`) are now recommended as they support additional features like supporting files
- Built-in commands like `/compact` and `/clear` are not affected

# Refine Backlog — GitHub Action

Transform messy backlog items into structured, actionable work items — directly in your GitHub workflow.

Powered by [Refine Backlog](https://refinebacklog.com).

---

## Quick Start

```yaml
- uses: DavidNielsen1031/refine-backlog-action@v1
  with:
    items: "Fix login bug\nAdd dark mode\nImprove search performance"
    key: ${{ secrets.REFINE_BACKLOG_KEY }}
```

---

## Inputs

| Input | Required | Default | Description |
|-------|----------|---------|-------------|
| `items` | ✓ (or `file`) | — | Newline-separated backlog items to refine |
| `file` | ✓ (or `items`) | — | Path to a file with items (one per line) |
| `key` | No | — | License key (or set `REFINE_BACKLOG_KEY` env var) |
| `user-stories` | No | `false` | Add a user story title to each item |
| `gherkin` | No | `false` | Write acceptance criteria in Given/When/Then format |
| `context` | No | — | Project context (e.g. `"B2B SaaS, TypeScript, team of 5"`) |
| `output-file` | No | — | Write JSON output to this file path |
| `write-back` | No | `false` | Post refined output as a comment on the triggering issue |

## Outputs

| Output | Description |
|--------|-------------|
| `refined` | JSON string of all refined backlog items |
| `count` | Number of items refined |

---

## Example Workflows

### 1. Refine Issues Automatically on Open

When a new issue is opened, automatically refine the title and post structured acceptance criteria as a comment.

```yaml
# .github/workflows/refine-on-issue.yml
name: Refine on Issue Open

on:
  issues:
    types: [opened]

jobs:
  refine:
    runs-on: ubuntu-latest
    permissions:
      issues: write
    steps:
      - uses: actions/checkout@v4

      - name: Refine issue
        uses: DavidNielsen1031/refine-backlog-action@v1
        with:
          items: ${{ github.event.issue.title }}
          write-back: "true"
          gherkin: "true"
          user-stories: "true"
          key: ${{ secrets.REFINE_BACKLOG_KEY }}
```

### 2. Refine a Backlog File on Demand

Trigger manually, refine a `backlog.txt` file, and commit the JSON output.

```yaml
# .github/workflows/refine-backlog-file.yml
name: Refine Backlog File

on:
  workflow_dispatch:
    inputs:
      file:
        description: "Path to backlog file"
        default: "backlog.txt"
        required: true

jobs:
  refine:
    runs-on: ubuntu-latest
    permissions:
      contents: write
    steps:
      - uses: actions/checkout@v4

      - name: Refine backlog
        id: refine
        uses: DavidNielsen1031/refine-backlog-action@v1
        with:
          file: ${{ inputs.file }}
          output-file: refined.json
          user-stories: "true"
          gherkin: "true"
          context: "B2B SaaS product"
          key: ${{ secrets.REFINE_BACKLOG_KEY }}

      - name: Commit refined output
        run: |
          git config user.email "action@github.com"
          git config user.name "Refine Backlog Action"
          git add refined.json
          git diff --staged --quiet || git commit -m "chore: update refined backlog (${{ steps.refine.outputs.count }} items)"
          git push

      - name: Summary
        run: echo "✅ Refined ${{ steps.refine.outputs.count }} items → refined.json"
```

### 3. Pipe Refined Output to Another Step

Use the `refined` output in subsequent steps — post to Slack, create Jira tickets, etc.

```yaml
- name: Refine backlog
  id: refine
  uses: DavidNielsen1031/refine-backlog-action@v1
  with:
    file: backlog.txt
    key: ${{ secrets.REFINE_BACKLOG_KEY }}

- name: Use the output
  run: |
    echo "Refined ${{ steps.refine.outputs.count }} items"
    echo '${{ steps.refine.outputs.refined }}' | jq '.[0].title'
```

---

## Setting Up Your License Key

1. Get a license key at [refinebacklog.com/pricing](https://refinebacklog.com/pricing)
2. Add it as a GitHub secret: **Settings → Secrets → Actions → New repository secret**
   - Name: `REFINE_BACKLOG_KEY`
   - Value: your license key (e.g. `RB-PRO-XXXX-XXXX-XXXX`)

**No key?** The free tier allows 3 requests/day, 5 items per request — enough to try it out.

---

## Pricing

| Tier | Price | Items/request | Requests/day |
|------|-------|--------------|--------------|
| Free | $0 | 5 | 3 |
| Pro | $9/mo | 25 | Unlimited |
| Team | $29/mo | 50 | Unlimited |

→ [Get a license key](https://refinebacklog.com/pricing)

---

## Links

- [Website](https://refinebacklog.com)
- [CLI on npm](https://www.npmjs.com/package/refine-backlog-cli)
- [MCP server](https://www.npmjs.com/package/refine-backlog-mcp)
- [API docs](https://refinebacklog.com/openapi.yaml)

# Agentic Engineering Harness

A batteries-included GitHub template for building **any** software project with Claude Code — combining three proven open-source systems into one disciplined, context-managed workflow that survives multi-month solo builds.

**The stack:**

| Layer | System | Job |
|---|---|---|
| Process | [Matt Pocock's skills](https://github.com/mattpocock/skills) | Grill → PRD → issues → TDD → two-axis review. You own the process; skills are small and composable. |
| Execution muscle | [Superpowers](https://github.com/obra/superpowers) (scoped) | Git-worktree isolation + subagent-driven plan execution for big features. |
| Code style | [Ponytail](https://github.com/DietrichGebert/ponytail) | Always-on "laziest senior dev" ladder — the best code is the code you never wrote. |
| Memory | This template | Versioned context architecture: ROADMAP, DECISIONS, CONTEXT.md domain language, ADRs, session logs. Claude never has to remember anything. |

Why the split? Process-owning frameworks are powerful but take control away; composable skills give control but no long-term memory or big-feature execution pattern. This harness takes each system's best part and writes down the precedence rules (`docs/HARNESS.md`) so they never fight.

> **New to any of this?** Read **[GUIDE.md](GUIDE.md)** — the complete walkthrough from zero (no tools installed, limited technical background) to your first AI-built feature. The quickstart below is the condensed version for experienced developers.

## Quickstart

1. Click **Use this template** → create your repo → clone → open in VS Code.
2. Run the init script and follow it:
   ```bash
   ./scripts/init.sh
   ```
   It renames the dot-folders, lets you pick a stack preset (Python / TypeScript / none), and prints the plugin-install commands.
3. In Claude Code, install the three systems (one-time per machine):
   ```
   /plugin install superpowers@claude-plugins-official
   /plugin marketplace add DietrichGebert/ponytail   →  /plugin install ponytail@ponytail
   ```
   ```bash
   npx skills@latest add mattpocock/skills   # select /setup-matt-pocock-skills too
   ```
4. Run `/setup-matt-pocock-skills` (choose your issue tracker + docs location), fill the `{{PLACEHOLDERS}}` in `CLAUDE.md`, then paste `KICKOFF-PROMPT.md` into Claude Code.

Full workflow manual: **`PLAYBOOK.md`**. System precedence rules: **`docs/HARNESS.md`**.

## What's inside

```
CLAUDE.md            # Lean always-on rules (placeholders to fill at init)
CONTEXT.md           # Your project's domain language — built by /grill-with-docs
PLAYBOOK.md          # The operating manual: loops, rituals, context rules
KICKOFF-PROMPT.md    # Staged initialization prompt for the first session
docs/
  HARNESS.md         # Which system fires when; conflict precedence
  ROADMAP.md         # Project memory between sessions
  DECISIONS.md       # Append-only decision log
  INTEGRATIONS.md    # Credentials matrix (env-var names, never values)
  BACKLOG.md         # Parking lot
  adr/  designs/  plans/  sessions/
dot-claude/          # → .claude/ : guardrail settings, custom subagents + commands
dot-github/          # → .github/ : importable security rulesets, workflow guide
presets/             # python/ (uv·ruff·pytest) and typescript/ (pnpm·biome·vitest)
scripts/init.sh
```

## The workflow in one breath

`/session-start` → `/grill-with-docs` the feature (builds CONTEXT.md + ADRs as a side effect) → `/to-prd` → `/to-issues` → per issue: TDD red-green-refactor (small) or Superpowers worktree + subagent execution (big) → `/code-review` (standards + spec, parallel subagents) → verifier subagent → merge behind branch rulesets → `/sync-tracker` → `/session-end` → `/clear`.

## Security by default

Importable GitHub rulesets (PR-only main, required CI, no force-push, immutable release tags), secret-scanning push-protection checklist, Claude Code permission denies on secrets and destructive commands, least-privilege guidance for bots. See `docs/REPO-SECURITY.md`.

## Credits & license

Built on [Superpowers](https://github.com/obra/superpowers) by Jesse Vincent, [Ponytail](https://github.com/DietrichGebert/ponytail) by Dietrich Gebert, and [skills](https://github.com/mattpocock/skills) by Matt Pocock — all MIT, all installed from their own repos (nothing vendored here). This template: MIT.

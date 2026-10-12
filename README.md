# Agentic Engineering Harness

A GitHub template for building **any** software project with Claude Code — a disciplined, context-managed workflow where the important rules are *enforced*, not just written down. Built for solo builders, from senior engineers to people who've never coded, on multi-month projects.

**What you get:**

| Layer | What | Job |
|---|---|---|
| Process | Owned skills in `.claude/skills/` | `/grill` → `/write-spec` → `/slice-tickets` → `tdd` → review. Versioned with your project, so nothing upstream can break it. |
| Gates | Hooks, sandbox, pre-push, CI | Claude can't finish while tests fail, can't read your `.env`, and nothing unchecked reaches `main`. |
| Review | Built-in `/code-review` + `/security-review`, a `verifier` subagent, optional AI PR review | Every acceptance criterion has a test; every diff gets an adversarial second look. |
| Memory | ROADMAP, DECISIONS, CONTEXT.md, ADRs, session logs | Every session picks up exactly where the last one ended. |
| Plugins | [Superpowers](https://github.com/obra/superpowers) (scoped), [Ponytail](https://github.com/DietrichGebert/ponytail) | Worktree + subagent execution for big features; the "write the least code that works" ladder. |
| Health | `/doctor` | One command tells you what's working, what isn't, and the exact fix. |

The design and its reasoning, based on Anthropic's AI-native SDLC guidance: `docs/designs/harness-v2.md`. Precedence and what's enforced: `docs/HARNESS.md`.

> **New to any of this?** Read **[GUIDE.md](GUIDE.md)** — the complete walkthrough from zero (no tools installed) to your first AI-built feature. The quickstart below is the condensed version.

## Quickstart

1. **Use this template** → create your repo → clone → open in VS Code.
2. Run the init script (picks a stack preset, installs it, optionally enables AI PR review):
   ```bash
   ./scripts/init.sh
   ```
3. Commit and push the setup, then install the two plugins in Claude Code (one-time per machine):
   ```
   /plugin install superpowers@claude-plugins-official
   /plugin marketplace add DietrichGebert/ponytail
   /plugin install ponytail@ponytail
   ```
4. Run `/doctor` and fix anything it flags, fill the `{{PLACEHOLDERS}}` in `CLAUDE.md`, then paste `KICKOFF-PROMPT.md` into Claude Code.

## What's inside

```
CLAUDE.md            # Lean always-on rules (placeholders to fill at init)
CONTEXT.md           # Your project's domain language — built by /grill
PLAYBOOK.md          # The operating manual: loops, rituals, releases, context rules
KICKOFF-PROMPT.md    # Staged initialization prompt for the first session
GUIDE.md             # Zero-to-first-feature walkthrough
docs/
  HARNESS.md         # Which system fires when; what's enforced and how to override
  ROADMAP.md  DECISIONS.md  INTEGRATIONS.md  BACKLOG.md  REPO-SECURITY.md
  adr/  designs/  tickets/  plans/  sessions/
.claude/
  skills/            # grill, write-spec, slice-tickets, tdd, diagnose (owned process)
  hooks/             # stop-check (tests gate), guard (.env, where no sandbox)
  agents/            # verifier, tracker-sync, integration-prober
  commands/          # /session-start, /session-end, /doctor, /run-checks, /sync-tracker
  settings.json      # sandbox, permissions, hooks, plugins
.github/rulesets/    # importable branch + tag protection
presets/             # python/ (uv·ruff·pytest), typescript/ (pnpm·biome·vitest), common/ (AI review)
scripts/             # init.sh, check.sh, doctor.sh, git-hooks/pre-push
```

## The workflow in one breath

`/session-start` → `/grill` the feature (builds CONTEXT.md + ADRs as a side effect) → `/write-spec` → `/slice-tickets` → **you approve** → per ticket: `tdd` red-green-refactor (small) or Superpowers worktree + subagents (big) → `/code-review` + `/security-review` + verifier → PR (pre-push + CI gate it) → merge → `/sync-tracker` → `/session-end` → `/clear`.

## Security by default

OS-level sandbox that blocks `.env` reads, permission denies on secrets and destructive commands, a Stop hook that enforces green tests, a local pre-push floor that works on every GitHub plan, importable rulesets (PR-only main, required CI, no force-push, immutable release tags), and an honest table of what your GitHub plan can and can't protect. See `docs/REPO-SECURITY.md`.

## Maintaining the template

`tests/harness/run.sh` is the harness's own test suite (CI: `.github/workflows/harness-ci.yml`); `init.sh` removes both from new projects. Run `tests/harness/run.sh --presets` before changing anything here.

## Credits & license

Process skills adapted from [mattpocock/skills](https://github.com/mattpocock/skills) by Matt Pocock (MIT — see `THIRD_PARTY.md`). Plugins: [Superpowers](https://github.com/obra/superpowers) by Jesse Vincent and [Ponytail](https://github.com/DietrichGebert/ponytail) by Dietrich Gebert, both MIT and installed from their own repos. This template: MIT.

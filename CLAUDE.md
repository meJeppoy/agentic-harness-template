# {{PROJECT_NAME}}

{{ONE_PARAGRAPH: what this project is, for whom, and the 3-5 core technologies.}}

{{OWNER_NAME}} (solo dev) builds this with Claude Code + the harness defined in `docs/HARNESS.md`. Issue tracker: {{TRACKER: GitHub Issues / Linear / local files — recorded in docs/DECISIONS.md D-003}}.

## Iron rules (never violate, never weaken)

1. **No secrets in code or context.** Credentials live in `.env` (gitignored) and CI secrets. Never read, print, or commit `.env*` contents; reference env-var names only (`docs/INTEGRATIONS.md`). The sandbox enforces this; don't work around it.
2. **Nothing merges that the owner can't explain.** Explain diffs in plain English on request; the owner is the reviewer of last resort.
3. **Tests are the contract.** TDD (red → green → refactor) for all behavior changes. Never weaken a test to make it pass. The Stop hook enforces green; declare a red step with `.claude/red-step` and remove it when green.
4. {{PROJECT_IRON_RULE_1: e.g., "No production writes — all warehouse access read-only"}}
5. {{PROJECT_IRON_RULE_2: delete if unused}}

## Workflow rules (see docs/HARNESS.md for full precedence)

- Start each session with `/session-start` (runs `/doctor` first); end with `/session-end`.
- Feature work starts with `/grill` — never straight to code. Then `/write-spec` → `/slice-tickets`. **No code until the owner approves the spec and tickets.**
- Small tickets: `tdd` on a branch. Large features: Superpowers worktree + subagent-driven execution, fed by the approved spec.
- **Do not** invoke Superpowers brainstorming or requesting-code-review; `/grill` and `/code-review` + the verifier own those jobs.
- Ponytail stays at `full`. Before writing code, climb the ladder: needed at all? → already in repo? → stdlib? → platform? → existing dep? → one line? → minimum that works.
- New domain terms → `CONTEXT.md`; hard-to-reverse decisions → `docs/adr/`; other decisions → `docs/DECISIONS.md`. Specs → `docs/designs/`, large-feature plans → `docs/plans/`, status → `docs/ROADMAP.md`. Same session, or it didn't happen.
- Checks run through `scripts/check.sh fast|full` only.

## Stack

- {{STACK: e.g., "Python 3.12 — uv, ruff, pytest (presets/python)" or "TypeScript — pnpm, biome, vitest (presets/typescript)"}}
- Deviations per component require a `docs/DECISIONS.md` entry with one-line justification, decided at grill time.

## Repo layout

```
src/ (or {{LAYOUT}})   # the product — structure decided at first grill
docs/                  # project knowledge — context map below
scripts/               # check.sh, doctor.sh, init.sh, git-hooks/
.claude/               # owned skills, hooks, subagents, commands, settings (sandbox)
.github/workflows/     # CI from preset; security rulesets in .github/rulesets/
```

## Context map (read on demand, not all at once)

- `CONTEXT.md` — domain language; read before touching unfamiliar modules.
- `docs/ROADMAP.md` — status; the project's memory between sessions.
- `docs/DECISIONS.md` — append-only; check before re-litigating.
- `docs/designs/` — specs with numbered acceptance criteria; `docs/tickets/` — local tickets.
- `docs/adr/` — architecture decision records from grilling.
- `docs/HARNESS.md` — precedence and what's enforced; re-read if unsure which skill applies.
- `docs/INTEGRATIONS.md` — external systems, env-var names, status.
- `PLAYBOOK.md` — the human workflow.

## Conventions

- Conventional commits; PRs reference issues ({{e.g., "Fixes #12" / "Fixes ABC-12"}}) and link the spec.
- Definition of done: code + `scripts/check.sh full` green + every acceptance criterion has a named test + `/code-review` and `/security-review` clean + verifier SHIP + tracker updated (`/sync-tracker`) + ROADMAP updated + DECISIONS/CONTEXT updated if anything was decided or named.

## What NOT to do

- Don't build ahead of the roadmap or without an approved spec.
- Don't add dependencies the stdlib or an existing dep covers (Ponytail rung 3-5).
- Don't write defensive boilerplate, dead abstractions, or verbose docstrings on trivial functions.
- Don't "fix" failing tests or checks by weakening them, and don't bypass a gate without a DECISIONS entry.

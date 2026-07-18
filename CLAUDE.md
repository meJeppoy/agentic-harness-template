# {{PROJECT_NAME}}

{{ONE_PARAGRAPH: what this project is, for whom, and the 3-5 core technologies.}}

{{OWNER_NAME}} (solo dev) builds this with Claude Code + the harness defined in `docs/HARNESS.md`. Issue tracker: {{TRACKER: GitHub Issues / Linear / local files — must match /setup-matt-pocock-skills config}}.

## Iron rules (never violate, never weaken)

1. **No secrets in code or context.** Credentials live in `.env` (gitignored) and CI secrets. Never read, print, or commit `.env*` contents; reference env-var names only (`docs/INTEGRATIONS.md`).
2. **Nothing merges that the owner can't explain.** Explain diffs in plain English on request; the owner is the reviewer of last resort.
3. **Tests are the contract.** TDD (red → green → refactor) for all behavior changes. Never weaken a test to make it pass.
4. {{PROJECT_IRON_RULE_1: e.g., "No production writes — all warehouse access read-only"}}
5. {{PROJECT_IRON_RULE_2: delete if unused}}

## Workflow rules (see docs/HARNESS.md for full precedence)

- Feature work starts with `/grill-with-docs` — never straight to code, even for "small" changes. Then `/to-prd` → `/to-issues`.
- Small issues: MP `/tdd` on a branch. Large features: Superpowers worktree + subagent-driven execution, fed by the PRD.
- **Do not** invoke Superpowers brainstorming or requesting-code-review; MP grilling and `/code-review` own those jobs.
- Ponytail stays at `full`. Before writing code, climb the ladder: needed at all? → already in repo? → stdlib? → platform? → existing dep? → one line? → minimum that works.
- Update `CONTEXT.md` (domain language) and `docs/adr/` when grilling surfaces new terms or decisions — that's what `/grill-with-docs` does; let it.
- Designs → `docs/designs/`, plans → `docs/plans/`, status → `docs/ROADMAP.md`, decisions → `docs/DECISIONS.md`. Same session, or it didn't happen.

## Stack

- {{STACK: e.g., "Python 3.12 — uv, ruff, pytest (presets/python)" or "TypeScript — pnpm, biome, vitest (presets/typescript)"}}
- Deviations per component require a `docs/DECISIONS.md` entry with one-line justification, decided at grill time.

## Repo layout

```
src/ (or {{LAYOUT}})   # the product — structure decided at first grill
docs/                  # project knowledge — context map below
.github/workflows/     # CI from preset; security rulesets in .github/rulesets/
```

## Context map (read on demand, not all at once)

- `CONTEXT.md` — domain language; read before touching unfamiliar modules.
- `docs/ROADMAP.md` — status; the project's memory between sessions.
- `docs/DECISIONS.md` — append-only; check before re-litigating.
- `docs/adr/` — architecture decision records from grilling sessions.
- `docs/HARNESS.md` — system precedence; re-read if unsure which skill applies.
- `docs/INTEGRATIONS.md` — external systems, env-var names, status.
- `PLAYBOOK.md` — the human workflow.

## Conventions

- Conventional commits; PRs reference issues ({{e.g., "Fixes #12" / "Fixes ABC-12"}}).
- Definition of done: code + tests green + `/code-review` clean + verifier pass + tracker updated (`/sync-tracker`) + ROADMAP updated + DECISIONS/CONTEXT updated if anything was decided or named.

## What NOT to do

- Don't build ahead of the roadmap.
- Don't add dependencies the stdlib or an existing dep covers (Ponytail rung 3-5).
- Don't write defensive boilerplate, dead abstractions, or verbose docstrings on trivial functions.
- Don't "fix" failing tests or checks by weakening them.

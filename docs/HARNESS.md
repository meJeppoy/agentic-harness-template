# HARNESS — which system fires when

The harness is mostly this repo: owned process skills, hooks, a sandbox, and memory files. Two external plugins add execution muscle and code style. This file is the referee. Claude reads it once per session (via CLAUDE.md) and follows it without exception.

## Precedence (highest wins)

1. **The user's explicit instruction** in the moment
2. **CLAUDE.md** project rules
3. **Owned process skills** in `.claude/skills/` (`/grill`, `/write-spec`, `/slice-tickets`, `tdd`, `diagnose`) — own the *process*
4. **Claude Code built-ins** — plan mode, `/code-review`, `/security-review`, hooks, sandbox
5. **Superpowers** — owns *execution mechanics* for large features only (worktrees, written plans, subagent-driven execution)
6. **Ponytail** — owns *code style*, always-on, never below `full`
7. Default model behavior

## The approval gate

**No implementation starts until the owner has approved the spec (`docs/designs/<feature>.md`) and its tickets.** Grill notes are the intent, the spec is the contract, tickets are the plan, the tracker is status (DECISIONS D-007). Small fixes whose whole diff fits in one sentence may skip the spec, but never the test.

## Division of labor

| Situation | Use | NOT |
|---|---|---|
| New feature / change — aligning on what to build | `/grill` | Superpowers brainstorming — do not let it fire |
| Grilled conversation → spec | `/write-spec` → owner approves | Superpowers writing-plans for small/medium work |
| Spec → buildable slices | `/slice-tickets` → owner approves | — |
| Small/medium ticket (≤ ~1 day) | `tdd` red → green → refactor, on a branch | Worktree ceremony |
| Large feature (multi-day, many files) | Superpowers: using-git-worktrees + writing-plans + subagent-driven-development, fed by the approved spec and tickets | Letting Superpowers re-interview you |
| Test discipline | `tdd` skill governs; Superpowers TDD defers to it | Two TDD doctrines at once |
| Reviewing a diff | `/code-review` + `/security-review` + `verifier` subagent; optional AI PR review in CI | Superpowers requesting-code-review |
| Hard bug | `diagnose` | Ad-hoc fixing |
| Design question needing evidence | a throwaway spike on a branch, deleted after; record the answer in DECISIONS | Building the real thing to find out |
| Over-engineering check | `/ponytail-review` on the diff; `/ponytail-audit` monthly | — |
| Is the harness working? | `/doctor` | Guessing |
| Session continuity | `/session-start`, `/session-end`, `docs/ROADMAP.md`, handoff docs in `docs/sessions/` | Relying on chat memory |

## What's enforced vs. advised

| Rule | Enforced by | Override (always visible) |
|---|---|---|
| Tests are the contract | Stop hook runs `scripts/check.sh`; Claude can't finish a turn while red | `.claude/red-step` during TDD red; `HARNESS_SKIP_STOP_CHECK=1 claude` for a session |
| No secrets in context | Sandbox denies `.env*` reads (macOS/Linux/WSL2); guard hook where no sandbox; `Read` deny rules | User runs the command themselves |
| Nothing unchecked reaches main | GitHub rulesets (public repos, or paid plans); local pre-push hook everywhere | `git push --no-verify`, logged in DECISIONS |
| Ruleset files untouched by Claude | `Edit` deny rule | User edits them |
| Everything else in CLAUDE.md | Instructions + verifier review | — |

## Why this split

Process skills are owned because the process is the product: a template others depend on can't break when an upstream author renames a skill (D-004). Built-ins are preferred wherever they cover a job because Anthropic maintains them. Superpowers is kept because isolated-worktree execution by fresh-context subagents is the best defense against context rot on big features. Ponytail is kept because every layer above it tends to over-build; its ladder (skip it → reuse it → stdlib → platform → dependency → one line → minimum that works) prunes at the point of writing.

## Conflict examples

- Superpowers' session-start hook says "invoke brainstorming before any creative work." CLAUDE.md overrides: grilling owns that job. Superpowers' own instruction-priority rules say CLAUDE.md wins — by design, not a hack. If it fires anyway, say "Stop. Follow docs/HARNESS.md — /grill first."
- Ponytail wants one line; the spec requires validation and error handling. No conflict: Ponytail never cuts trust-boundary validation, data-loss handling, security, or accessibility.
- `tdd` wants a failing test first; Superpowers subagent executors also enforce TDD. Same doctrine; the `tdd` skill's wording governs if they differ.

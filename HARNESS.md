# HARNESS — which system fires when

Three systems are installed; they overlap. This file is the referee. Claude reads it once per session (via CLAUDE.md) and follows it without exception.

## Precedence (highest wins)

1. **The user's explicit instruction** in the moment
2. **CLAUDE.md** project rules
3. **Matt Pocock skills** — own the *process*
4. **Superpowers** — owns *execution mechanics* only where MP has no equivalent
5. **Ponytail** — owns *code style*, always-on, never disabled below `full`
6. Default model behavior

## Division of labor

| Situation | Use | NOT |
|---|---|---|
| New feature / change — aligning on what to build | `/grill-with-docs` (MP) | Superpowers brainstorming — do not let it fire |
| Converting an aligned conversation into a spec | `/to-prd` → `/to-issues` (MP) | Superpowers writing-plans for small/medium work |
| Small/medium issue (≤ ~1 day) | MP `/tdd` red-green-refactor, directly on a branch | Worktree ceremony |
| Large feature (multi-day, many files) | Superpowers: using-git-worktrees + writing-plans + subagent-driven-development — fed by the MP-produced PRD/issues, not its own brainstorm | Letting Superpowers re-interview you |
| Test discipline | MP `/tdd` rules govern; Superpowers TDD skill defers to them | Two TDD doctrines at once |
| Reviewing a diff | MP `/code-review` (standards + spec axes) + this repo's `verifier` subagent | Superpowers requesting-code-review |
| Hard bug | MP `/diagnosing-bugs` | Ad-hoc fixing; Superpowers systematic-debugging is acceptable fallback if MP skill unavailable |
| Design question needing evidence | MP `/prototype` or `/research` | Building the real thing to find out |
| Over-engineering check | `/ponytail-review` on the diff; `/ponytail-audit` monthly | — |
| Issue hygiene | MP `/triage` | — |
| Session continuity | This repo: `/session-start`, `/session-end`, `docs/ROADMAP.md` | Relying on chat memory |
| Mid-work handoff | MP `/handoff` → save output to `docs/sessions/` | — |

## Why MP leads

Process-owning frameworks make their own decisions about how you work; when the process breaks you debug the framework instead of the code. MP skills are small, composable, and leave you in control — the right default for a solo developer who must be able to explain everything that ships. Superpowers is kept because MP has no answer for isolated-workspace execution of large plans by fresh-context subagents, and that pattern is the single best defense against context rot on big features. Ponytail is kept because every system above it tends to over-build; the ladder (skip it → reuse it → stdlib → platform → dependency → one line → minimum that works) prunes at the point of writing.

## Conflict examples

- Superpowers' using-superpowers skill says "invoke brainstorming before EnterPlanMode." CLAUDE.md overrides: grilling already happened or will happen via MP. Per Superpowers' own instruction-priority rules, CLAUDE.md wins — this is by design, not a hack.
- Ponytail wants one line; the PRD requires validation and error handling. No conflict: Ponytail's own rules never cut trust-boundary validation, data-loss handling, security, or accessibility.
- MP `/tdd` wants a failing test first; Superpowers subagent executors also enforce TDD. Fine — same doctrine; MP's wording governs if they differ.

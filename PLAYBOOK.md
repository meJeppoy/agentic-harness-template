# PLAYBOOK — how projects get built with this harness

The operating manual. CLAUDE.md holds the rules Claude always knows; `docs/HARNESS.md` referees the systems and lists what's enforced; this file holds the workflow *you* run.

## 1. The operating model

| Layer | Job | Lives in |
|---|---|---|
| **Project knowledge** (durable) | What, why, decisions, domain language | `CLAUDE.md`, `CONTEXT.md`, `docs/` |
| **Build state** (per-feature) | Specs, tickets, plans, progress | `docs/designs/`, tracker or `docs/tickets/`, `docs/plans/`, `docs/ROADMAP.md` |
| **Process** (owned) | How work gets done | `.claude/skills/` — grill, write-spec, slice-tickets, tdd, diagnose |
| **Gates** (enforced) | What can't be skipped | Stop hook, sandbox, pre-push, rulesets + CI — see HARNESS.md |
| **Plugins** (installed once) | Big-feature execution, code style | Superpowers, Ponytail |

Context rot is prevented structurally: grilling front-loads alignment so you don't burn context on rework; big features execute in fresh-context subagents inside worktrees; durable knowledge lives in files so every session can reconstruct the world in under a minute.

## 2. The feature cycle

```
/session-start                     # doctor + ROADMAP + last session log + open decisions + tracker
/grill                             # relentless interview until every decision is settled;
                                   #   updates CONTEXT.md + docs/adr/ as it goes
/write-spec                        # → docs/designs/<feature>.md with numbered acceptance criteria
/slice-tickets                     # → vertical slices with blocking edges, each naming its ACs
  ── owner approves spec + tickets (no code before this) ──
per ticket:
  small (≤ ~1 day)  → tdd on a branch: red (.claude/red-step) → green → refactor
  large (multi-day) → Superpowers: worktree + written plan + subagent-driven execution
/code-review                       # built-in review of the diff
/security-review                   # built-in security pass
verifier subagent                  # spec ACs → tests, iron rules, gate hygiene
/ponytail-review                   # over-engineering delete-list on the diff
push branch → PR                   # pre-push runs checks; CI must be green; AI review comments (if enabled)
merge (squash)                     # "Fixes <ticket-ref>" in the PR
/sync-tracker                      # board reflects reality
/session-end                       # ROADMAP, DECISIONS, session log, gate audit
/clear                             # next unit of work starts fresh
```

Rules of thumb:

- **Grill every change.** The most common failure is misalignment, not bad code. If grilling feels like overkill, the change is small enough that grilling takes two minutes.
- **Vertical slices.** Each ticket independently shippable and testable — that's what makes both TDD and subagent execution work.
- **Acceptance criteria are the contract.** Every AC gets a named test; the verifier checks the mapping.
- **One worktree at a time** as a solo dev; finish and merge before the next big feature.
- **Uncertain?** Spike it on a throwaway branch, record the answer in DECISIONS, delete the branch.
- **Hard bug?** `diagnose` — feedback loop → reproduce → minimise → hypothesise → instrument → fix with regression test. Never fix without reproducing.
- **Park ideas** in `docs/BACKLOG.md`; get back to the slice.

## 3. The daily ritual

**Start** `/session-start` · **work** one ticket · **end** `/session-end`, never skip it. Interrupted mid-ticket? `/session-end` writes a handoff doc in `docs/sessions/` — that's your resume point.

## 4. Context-management rules

1. CLAUDE.md stays under ~90 lines; prune anything Claude does right without being told, and turn rules that must always hold into hooks.
2. Load narrow: the module's CONTEXT.md terms, the spec, and the ticket at hand — not the whole docs tree.
3. Noise goes to subagents: test runs (`/run-checks`), probes (integration-prober), board reads (tracker-sync).
4. Decisions are written (DECISIONS.md), terms are named (CONTEXT.md) — same session, or it didn't happen.
5. `/clear` at every ticket boundary; compaction is a fallback, not a strategy. Two failed corrections in a row → `/clear` and restate the task smaller.
6. Weekly hygiene: prune CLAUDE.md, reconcile ROADMAP, groom the tracker, `/doctor`; `/ponytail-audit` monthly.

## 5. Releasing and rolling back

- **Release** = a `v*` tag on a green `main` (tags are immutable under the rulesets): `git tag v1.2.0 && git push origin v1.2.0`. Note what shipped in ROADMAP.
- **Roll back** by reverting, never by force-pushing: `git revert <merge-commit>` on a branch → PR → merge. For a bad release, tag the revert as the next patch version.
- **Every production incident becomes a test.** Use `diagnose` to reproduce it, land the regression test with the fix, and count it on the session log's "Escaped bugs" line. Repeated escapes in one area = re-grill that area.
- Deployment itself is per-project: decide it at grill time and record it in an ADR.

## 6. Running Claude unattended (advanced)

For mechanical, well-specified work (a migration across many files, a batch of lint fixes): `claude -p "<task>" --allowedTools "Edit,Bash(scripts/check.sh *)" --permission-mode dontAsk` in a worktree, or `/batch` for fan-out. The Stop hook and pre-push still gate the result. Never run unattended work against `main`, and still review the PR.

## 7. Risk rules for a solo dev

- Never merge what you can't explain — ask for the plain-English diff walk-through.
- The verifier is your adversarial second reviewer; the AI PR review (if enabled) is a third, in comments only.
- Probe external integrations in isolation (integration-prober) before any plan depends on them.
- Git is the undo button: squash merges, no force-push, immutable release tags.
- A gate that blocks you wrongly gets fixed or overridden *with a DECISIONS entry* — never silently deleted.

## 8. When things go wrong

- Claude in circles → `/clear`, `/session-start`, narrow to one ticket.
- Requirement changed mid-build → update the spec first, re-grill the delta, then code.
- Something feels broken → `/doctor`.
- Lost? → `docs/ROADMAP.md` + the newest file in `docs/sessions/` + `docs/HARNESS.md`.

# PLAYBOOK — how projects get built with this harness

The operating manual. CLAUDE.md holds the rules Claude always knows; `docs/HARNESS.md` referees the three systems; this file holds the workflow *you* run.

## 1. The operating model

| Layer | Job | Lives in |
|---|---|---|
| **Project knowledge** (durable) | What, why, decisions, domain language | `CLAUDE.md`, `CONTEXT.md`, `docs/` |
| **Build state** (per-feature) | PRDs, issues, designs, plans, progress | tracker + `docs/designs|plans|ROADMAP.md` |
| **Skills** (installed once) | How work gets done | MP skills, Superpowers, Ponytail |

Context rot is prevented structurally: grilling front-loads alignment so you don't burn context on rework; big features execute in fresh-context subagents inside worktrees; durable knowledge lives in files so every session can reconstruct the world in under a minute.

## 2. The feature cycle

```
/session-start                     # orient: ROADMAP + last session log + open decisions + tracker
/grill-with-docs                   # relentless interview until every branch of the decision tree
                                   #   is resolved; updates CONTEXT.md + docs/adr/ as it goes
/to-prd                            # conversation → PRD, published to the tracker
/to-issues                         # PRD → independently-grabbable vertical slices
per issue:
  small (≤ ~1 day)  → MP /tdd on a branch: red → green → refactor
  large (multi-day) → Superpowers: worktree + written plan + subagent-driven execution
/code-review                       # two axes in parallel subagents: standards + spec
verifier subagent                  # this repo's adversarial pass against CLAUDE.md iron rules
/ponytail-review                   # over-engineering delete-list on the diff
merge (rulesets enforce PR + CI)   # squash; "Fixes <issue-ref>" in the PR
/sync-tracker                      # board reflects reality
/session-end                       # ROADMAP, DECISIONS, session log, commit
/clear                             # next unit of work starts fresh
```

Rules of thumb:

- **Grill every change.** The most common failure is misalignment, not bad code. If grilling feels like overkill, the change is small enough that grilling takes two minutes.
- **Vertical slices.** Each issue independently shippable and testable — that's what makes both TDD and subagent execution work.
- **One worktree at a time** as a solo dev; finish and merge before the next big feature.
- **Uncertain?** `/prototype` (throwaway, radically different variants) or `/research` (cited findings doc) before committing a design.
- **Hard bug?** `/diagnosing-bugs` — reproduce → minimise → hypothesise → instrument → fix → regression-test. Never fix without reproducing.
- **Park ideas** in `docs/BACKLOG.md` or the tracker via `/triage`; get back to the slice.

## 3. The daily ritual

**Start** `/session-start` · **work** one feature-cycle unit · **end** `/session-end`, never skip it. Interrupted mid-work? `/handoff`, save the output to `docs/sessions/`, and that's your resume point.

## 4. Context-management rules

1. CLAUDE.md stays under ~90 lines; prune anything Claude does right without being told.
2. Load narrow: the module's CONTEXT.md terms and the issue at hand — not the whole docs tree.
3. Noise goes to subagents: test runs (`/run-checks`), probes (integration-prober), board reads (tracker-sync).
4. Decisions are written (DECISIONS.md), terms are named (CONTEXT.md) — same session, or it didn't happen.
5. `/clear` at every issue boundary; compaction is a fallback, not a strategy.
6. Weekly hygiene: prune CLAUDE.md, reconcile ROADMAP, `/triage` the tracker, run `/improve-codebase-architecture` every few days on active codebases, `/ponytail-audit` monthly.

## 5. Risk rules for a solo dev

- Never merge what you can't explain — ask for the plain-English diff walk-through.
- The verifier subagent is your adversarial second reviewer; the rulesets (`docs/REPO-SECURITY.md`) make bypassing the process structurally impossible.
- Probe external integrations in isolation (integration-prober) before any plan depends on them.
- Git is the undo button: squash merges, no force-push, immutable release tags.

## 6. When things go wrong

- Claude in circles → `/clear`, `/session-start`, narrow to one slice.
- Requirement changed mid-build → update the PRD/issue first, re-grill the delta, then code.
- Lost? → `docs/ROADMAP.md` + `docs/sessions/` tail + `/ask-matt` (routes you to the right skill).

# Kickoff Prompt — first Claude Code session in a new project

Prerequisites: `./scripts/init.sh` done, plugins installed (Superpowers, Ponytail, MP skills), `/setup-matt-pocock-skills` run, CLAUDE.md placeholders filled, scaffold committed. Then paste everything between the lines.

---

I'm initializing this project on the agentic engineering harness. Work in four gated stages with a hard stop for my approval after each.

**STAGE 1 — Orient (no changes).**
Read `CLAUDE.md`, `PLAYBOOK.md`, `docs/HARNESS.md`, `docs/ROADMAP.md`, `docs/DECISIONS.md`, `docs/INTEGRATIONS.md`, and `CONTEXT.md`. Report back, max 15 lines: (a) the project in your own words, (b) the iron rules binding you, (c) the harness division of labor in one sentence per system, (d) anything contradictory, unfilled ({{placeholders}}), or unclear I should fix now. STOP.

**STAGE 2 — Verify the environment (read-only; propose fixes, don't install unasked).**
PASS/FAIL table: Ponytail active at `full` (run `/ponytail` to check); Superpowers installed (name 2 skills as proof); MP skills installed (name 3) and `/setup-matt-pocock-skills` config present; stack-preset toolchain runs (test runner + linter); git clean; `.claude/` commands and subagents discoverable; tracker connection works; env vars from `docs/INTEGRATIONS.md` present (names only). STOP.

**STAGE 3 — Toolchain baseline (the smallest full cycle).**
Run "repo toolchain baseline" through the harness end-to-end so I see every gear turn once: brief grill (scope questions only), a one-slice issue, TDD a trivial smoke test, CI green locally, `/code-review`, update `docs/ROADMAP.md`, commit. Scope strictly: toolchain + one smoke test + CI workflow — nothing else. STOP and show me.

**STAGE 4 — Grill the first real feature (design only, no code).**
Run `/grill-with-docs` on the first item in `docs/ROADMAP.md`. Interview me until every branch of the decision tree is resolved; capture domain terms into `CONTEXT.md` and decisions into `docs/adr/` as you go. Finish with `/to-prd` and `/to-issues` so the tracker holds vertical slices. Then STOP — we build the first slice next session, fresh.

Throughout: `docs/HARNESS.md` precedence governs; anything decided goes to `docs/DECISIONS.md` in the same session; end today with `/session-end`.

---

## After this session

Next session: `/session-start` → grab the first issue → `/tdd` (small) or Superpowers worktree (large). The PLAYBOOK §2 cycle repeats per issue. The prompt is idempotent — re-run a stalled stage alone.

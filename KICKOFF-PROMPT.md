# Kickoff Prompt — first Claude Code session in a new project

Prerequisites: `./scripts/init.sh` done and the setup pushed, pre-push hook enabled, plugins installed (Superpowers, Ponytail), `/doctor` has no FAILs, CLAUDE.md placeholders and DECISIONS D-003 (tracker) filled. Then paste everything between the lines.

---

I'm initializing this project on the agentic engineering harness. Work in four gated stages with a hard stop for my approval after each.

**STAGE 1 — Orient (no changes).**
Read `CLAUDE.md`, `PLAYBOOK.md`, `docs/HARNESS.md`, `docs/ROADMAP.md`, `docs/DECISIONS.md`, `docs/INTEGRATIONS.md`, and `CONTEXT.md`. Report back, max 15 lines: (a) the project in your own words, (b) the iron rules binding you and which ones hooks enforce, (c) the harness division of labor in one sentence per layer, (d) anything contradictory, unfilled ({{placeholders}}), or unclear I should fix now. STOP.

**STAGE 2 — Verify the environment (read-only; propose fixes, don't install unasked).**
Run `/doctor`. Explain each FAIL and WARN in plain English with its fix, most important first. Also confirm: Ponytail active at `full`; `/grill`, `/write-spec`, `/slice-tickets`, `tdd`, `diagnose` are available; the tracker in D-003 is reachable; env vars from `docs/INTEGRATIONS.md` present (names only). STOP.

**STAGE 3 — Toolchain baseline (the smallest full cycle).**
Run "repo toolchain baseline" through the harness end-to-end so I see every gear turn once: a two-question `/grill`, a one-criterion spec, one ticket, `tdd` a trivial smoke test (red step with `.claude/red-step` → green → remove marker), `scripts/check.sh full` green, `/code-review`, verifier, branch + PR with CI green, update `docs/ROADMAP.md`. If no preset was chosen, pick the toolchain with me first and record it as D-002. Scope strictly: toolchain + one smoke test + CI — nothing else. STOP and show me.

**STAGE 4 — Grill the first real feature (design only, no code).**
Run `/grill` on the first item in `docs/ROADMAP.md`. Interview me until every branch of the decision tree is resolved; capture domain terms into `CONTEXT.md` and decisions into `docs/adr/` or `docs/DECISIONS.md` as you go. Finish with `/write-spec` and `/slice-tickets` so the tracker holds approved vertical slices. Then STOP — we build the first slice next session, fresh.

Throughout: `docs/HARNESS.md` precedence governs; anything decided goes to `docs/DECISIONS.md` in the same session; end today with `/session-end`.

---

## After this session

Next session: `/session-start` → grab the first ticket → `tdd` (small) or Superpowers worktree (large). The PLAYBOOK §2 cycle repeats per ticket. The prompt is idempotent — re-run a stalled stage alone.

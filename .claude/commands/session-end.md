---
description: Close out the session — persist state, sync tracker, write the session log
---

Close out this working session:

1. **Decisions & language:** scan the session for anything decided → append to `docs/DECISIONS.md` (or an ADR); any new domain terms → `CONTEXT.md`.
2. **State:** update `docs/ROADMAP.md` (statuses + the "Now" line); move finished plans to `docs/plans/done/`; update `docs/INTEGRATIONS.md` if access changed.
3. **Gates:** report anything that weakened a gate this session — an open `.claude/red-step`, `HARNESS_SKIP_STOP_CHECK`, a `--no-verify` push, a skipped or disabled check. Each needs a one-line reason in `docs/DECISIONS.md`, or gets undone now.
4. **Git:** show me anything uncommitted and ask before committing (conventional commits). Never commit `.env*`, `.claude/red-step`, or temp artifacts.
5. **Tracker:** invoke the `tracker-sync` subagent.
6. **Session log:** write `docs/sessions/YYYY-MM-DD-<n>.md`, exactly six lines: Did / Shipped / Decided / Blocked / Escaped bugs (bugs found after something was marked done, or "none") / Next time.
7. **Confirm:** 3-line summary — what's persisted, board status, recommended first command next session.

If work stopped mid-ticket, also write `docs/sessions/YYYY-MM-DD-<n>-handoff.md`: the ticket and spec, what's done, what's in progress (files, failing test if any), the exact next step, and anything learned the hard way. `/session-start` reads it as the resume point.

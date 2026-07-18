---
description: Close out the session — persist state, sync tracker, write the session log
---

Close out this working session:

1. **Decisions & language:** scan the session for anything decided → append to `docs/DECISIONS.md` (or an ADR); any new domain terms → `CONTEXT.md`.
2. **State:** update `docs/ROADMAP.md` (statuses + the "Now" line); move finished plans to `docs/plans/done/`; update `docs/INTEGRATIONS.md` if access changed.
3. **Git:** show me anything uncommitted and ask before committing (conventional commits). Never commit `.env*` or /tmp artifacts.
4. **Tracker:** invoke the `tracker-sync` subagent.
5. **Session log:** write `docs/sessions/YYYY-MM-DD-<n>.md`, exactly five lines: Did / Shipped / Decided / Blocked / Next time.
6. **Confirm:** 3-line summary — what's persisted, board status, recommended first command next session.

If work is mid-issue, also run `/handoff` and save its output to `docs/sessions/` alongside the log.

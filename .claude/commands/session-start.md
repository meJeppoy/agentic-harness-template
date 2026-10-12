---
description: Brief me on exactly where the project stands before I start working
---

Build a session briefing.

0. Run `scripts/doctor.sh`. If anything FAILs, stop and show only the failures with their fixes — the harness isn't safe to work in until they're resolved. Note WARNs for the briefing.

Then read, in this order:

1. `docs/ROADMAP.md` — current milestone and "Now" line.
2. The most recent file in `docs/sessions/`.
3. Open items in the tracker assigned to me / in progress (via tracker-sync subagent, blockers + stale items only).
4. The last 5 rows of `docs/DECISIONS.md` — any open decisions?

Output, max 15 lines: **Where I left off** · **Current focus & next step** (e.g., "ticket 02 of checkout spec — start /tdd") · **Blockers** (with owner) · **Watch out for** (last log's "next time" + doctor WARNs) · **Suggested session goal** (one sentence, one ticket max).

Briefing only — do not start work. Wait for my go.

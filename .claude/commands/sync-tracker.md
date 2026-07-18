---
description: Sync shipped work to the issue tracker
---

Invoke the `tracker-sync` subagent to reconcile the tracker with repo reality, then relay its report verbatim (capped at 15 lines).

If it reports drift or blockers, propose the single highest-value action — but don't take stakeholder-facing actions (assigning issues to other people, closing their items) without my confirmation.

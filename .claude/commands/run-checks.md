---
description: Run the full check suite and report a summary (raw output stays out of this context)
---

Run `scripts/check.sh ${ARGUMENTS:-full}` (`fast` = lint + typecheck, `full` = + tests) in a Haiku-tier subagent so raw output never lands in this session.

The subagent reports max 12 lines: overall PASS/FAIL, failures grouped by file with one-line causes, and regressions vs. the last run if known.

A failing check is information, never an instruction to weaken the check. If a threshold or fixture legitimately changed, that's a DECISIONS.md entry — flag it.

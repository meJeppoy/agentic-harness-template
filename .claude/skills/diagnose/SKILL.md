---
name: diagnose
description: Diagnosis loop for hard bugs and performance regressions — build a red-capable feedback loop, reproduce, minimise, hypothesise, instrument, fix with a regression test. Use when the user says "diagnose"/"debug this", or reports something broken, throwing, failing, or slow.
---

<!-- Adapted from mattpocock/skills@49dd158 (diagnosing-bugs), MIT. See THIRD_PARTY.md. -->

# Diagnose

A discipline for hard bugs. Skip phases only when explicitly justified. Read `CONTEXT.md` for a mental model of the modules involved, and check ADRs in the area.

## Redact

You'll show commands, outputs and captured artifacts. **Redact every secret first** (`<REDACTED>`); never read `.env` (CLAUDE.md iron rule 1). Build loops against env-var names so credentials stay in the environment. If redacted output isn't enough, say so and ask the user.

## Phase 1: Build a feedback loop

**This is the skill.** With a **tight** pass/fail signal that goes red on _this_ bug, you will find the cause. Without one, no amount of staring at code will save you. Spend disproportionate effort here.

Ways to build one, roughly in order: a failing test at whatever seam reaches the bug · a curl/HTTP script against a dev server · a CLI run with a fixture input diffed against a known-good snapshot · a headless-browser script · replaying a captured trace · a throwaway harness around one code path · a property/fuzz loop for "sometimes wrong" bugs · a `git bisect run` harness between a good and bad state · a differential run (old vs new version) · last resort, a human-in-the-loop script built from [scripts/hitl-loop.template.sh](scripts/hitl-loop.template.sh).

**Tighten it**: faster (narrow scope, cache setup), sharper (assert the specific symptom, not "didn't crash"), deterministic (pin time, seed randomness, isolate filesystem and network). For flaky bugs, raise the reproduction rate (loop 100×, add stress) until it's debuggable.

If you genuinely can't build a loop, stop and say so: list what you tried and ask for access to a reproducing environment, a redacted artifact (logs, HAR, recording), or permission for temporary instrumentation. **Do not hypothesise without a loop.**

**Done when** you can name one command you have already run (show it and its redacted output) that is red-capable (drives the real code path and asserts the user's exact symptom), deterministic, fast (seconds), and agent-runnable.

## Phase 2: Reproduce + minimise

Run the loop and watch it go red. Confirm it's the failure the **user** described, reproducible across runs, with the exact symptom captured. Then cut inputs, callers, config, data and steps one at a time, re-running after each cut, until every remaining element is load-bearing.

## Phase 3: Hypothesise

Write **3–5 ranked, falsifiable hypotheses** before testing any: "If X is the cause, then changing Y makes it disappear." Show the list to the user; they often re-rank instantly. Don't block if they're away.

## Phase 4: Instrument

Each probe maps to one prediction; change one variable at a time. Prefer a debugger/REPL, then targeted logs at the boundaries that distinguish hypotheses. Tag every debug log with a unique prefix (e.g. `[DEBUG-a4f2]`) so cleanup is one grep. For performance regressions, measure a baseline first, then bisect.

## Phase 5: Fix + regression test

Write the regression test **before** the fix, at a seam that exercises the real bug pattern, using the `tdd` loop (red-step marker included). If no correct seam exists, that is itself the finding: note it for the user. Watch the test fail, apply the fix, watch it pass, then re-run the original Phase 1 loop.

## Phase 6: Cleanup

- [ ] Original repro no longer reproduces
- [ ] Regression test passes (or the missing seam is documented)
- [ ] All `[DEBUG-...]` instrumentation removed
- [ ] Throwaway harnesses deleted
- [ ] The confirmed hypothesis is stated in the commit / PR message

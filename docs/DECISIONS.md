# Decision Log (append-only)

One line of context, the decision, the date. Newest at the bottom. Reversals get a new entry — never edit history. Check before re-litigating anything. Bigger decisions with full reasoning → `docs/adr/` (this file then links to the ADR).

| ID | Date | Decision | Context / consequence |
|----|------|----------|----------------------|
| D-001 | {{DATE}} | Harness adopted: MP skills lead the process; Superpowers scoped to worktrees + subagent execution; Ponytail always-on at `full` | See docs/HARNESS.md. |
| D-002 | {{DATE}} | Stack: {{STACK_CHOICE + preset}} | Deviations per component need a new D-entry. |
| D-003 | {{DATE}} | Tracker: {{TRACKER_CHOICE}} (configured via /setup-matt-pocock-skills) | /sync-tracker + /triage operate on it. |
| D-004 | 2026-10-11 | Harness v2: own the process skills (vendor MP subset @49dd158, renamed) and pin external plugins | MP churns fast with breaking renames, single maintainer; our docs already referenced dead names. See docs/designs/harness-v2.md. |
| D-005 | 2026-10-11 | Enforce tests and secrets with hooks + sandbox, not prose; every gate has a plain-English message and a logged override | CLAUDE.md is advisory; gates without overrides get deleted. |
| D-006 | 2026-10-11 | Claude PR review is opt-in and shadow-mode (comments, not a required check) | Token cost/setup for non-coders; prompt-injection risk; Anthropic shadow-runs AI reviewers before gating. |
| D-007 | 2026-10-11 | No new state files: spec = docs/designs/<feature>.md, tickets = plan, tracker = status; no features.json | One source of truth per fact; duplicates drift. |
| D-008 | 2026-10-11 | Deterministic harness smoke tests instead of agent-behaviour evals | Evals are flaky/costly; revisit when real incidents exist. |
| D-009 | 2026-10-11 | Local pre-push hook as the merge floor; doctor warns when rulesets can't apply | Rulesets and branch protection are public-repo-only on GitHub Free. |

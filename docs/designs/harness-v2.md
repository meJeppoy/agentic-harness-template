# Design: Harness v2 — from written rules to enforced gates

Status: **approved for build** (2026-10-11) · Plan: `docs/plans/harness-v2.md` · Decisions: D-004 – D-009

## Goal

A dependable AI-driven build system that a solo developer — experienced engineer or non-coder — can clone and use daily to ship reliable code fast. Not foolproof; dependable: the important rules hold even when the AI forgets them, failures explain themselves in plain English, and nothing silently degrades.

## Non-goals

- Foolproof security. Guards stop accidents and common mistakes, not a determined attacker.
- Deploy automation. Per-project; decided at grill time. We ship release/rollback *guidance* only.
- Agent-behaviour evals. Deferred until real incidents exist to turn into cases (D-008).
- Parallel-agent orchestration beyond Superpowers worktrees.

## Problem

v1 encodes discipline as *instructions* (CLAUDE.md, PLAYBOOK). Anthropic's own guidance: CLAUDE.md is advisory, hooks are deterministic. Scouting and an adversarial review found:

1. **Nothing enforces "tests are the contract."** The AI can claim done without green checks.
2. **Secret protection is prompt-level.** `Read(.env)` deny doesn't stop `cat .env` via Bash.
3. **The merge gate is absent for most target users.** Rulesets *and* classic branch protection are public-repo-only on GitHub Free ([source](https://github.com/github/docs/tree/main/data/reusables/gated-features)); GUIDE.md tells beginners to go Private. The template repo itself has no rulesets applied.
4. **The process depends on a fast-churning single-maintainer pack.** MP skills renamed `to-prd`→`to-spec`, deleted `to-issues` (→`to-tickets`), renamed `CONTEXT.md`→`GLOSSARY.md`. Our docs already reference three dead names; GUIDE.md breaks at feature-loop step 2.
5. **No setup check.** Missing plugins, skills, sandbox deps, or branch protection degrade the system silently.
6. **Presets start red.** `pnpm ci` collides with pnpm's built-in `ci`; no lockfile/tsconfig/tests → CI fails out of the box, training users to ignore red.
7. **Stale/dead scaffolding.** README describes `dot-claude/`; `init.sh` rename steps never run; `cp -n` + `set -e` aborts re-runs on newer coreutils.

## Design principles

- **Enforce the few rules that matter; advise the rest.** Hooks for tests and secrets; prose for style.
- **Every gate has a plain-English failure message and a logged override.** A gate that can't be bypassed gets deleted; a bypass that isn't visible is a hole.
- **One source of truth per fact.** No new state files; map Anthropic's intent→spec→plan chain onto what exists.
- **Own what the process depends on; pin what we borrow.**
- **Fail loud, not open.** Where a protection is unavailable, the doctor says so.

## Architecture: six layers

| Layer | Catches | Mechanism |
|---|---|---|
| 1. Plan gate | building the wrong thing | `/grill` → `/write-spec` → `/slice-tickets`; human approves spec + tickets before code (HARNESS.md rule) |
| 2. Build loop | unverified "done", dangerous actions | Stop hook → `scripts/check.sh`; sandbox + credential deny; guard hook fallback |
| 3. Review gate | blind spots of the author | verifier (fresh context, diff + spec only, evidence required) + built-in `/security-review` + `/code-review` |
| 4. Merge gate | unchecked code reaching main | rulesets where available; local `pre-push` floor everywhere |
| 5. Memory | drift between sessions | ROADMAP, DECISIONS, CONTEXT.md, ADRs, session logs (unchanged) |
| 6. Learning | repeat mistakes | incident → regression test; session log "escaped bugs" line; harness smoke tests |

## Components

### C1. Owned process skills (D-004)
Vendor the MP skills the process uses into `.claude/skills/`, renamed so upstream can never collide: `grill` (from grill-with-docs), `write-spec` (to-spec), `slice-tickets` (to-tickets), `tdd`, `diagnose` (diagnosing-bugs). Source: `mattpocock/skills@49dd158`, MIT, attribution + source commit in each file's header and `THIRD_PARTY.md`. Adapt to our files: glossary stays `CONTEXT.md`; specs → `docs/designs/<feature>.md`; local tickets → `docs/tickets/<feature>/NN-slug.md`; tracker choice read from DECISIONS D-003 (replaces `/setup-matt-pocock-skills`). Upstream changes come in only as a reviewed PR.

### C2. Pinned externals (D-004)
Superpowers stays, scoped to worktrees + subagent execution, pinned to a known version. Ponytail stays, pinned. Install docs drop `npx skills`. First-party Claude Code built-ins (plan mode, `/code-review`, `/security-review`, hooks, sandbox) are preferred wherever they cover a job.

### C3. Single check entry point
`scripts/check.sh [fast|full]` — the one place check commands live. `fast` = lint + typecheck; `full` = fast + tests. Used by the Stop hook, `/run-checks`, pre-push, and CI. Presets supply its body. Exits non-zero with a one-line plain-English summary.

### C4. Stop hook — verification gate (D-005)
`.claude/hooks/stop-check.sh`, registered in `.claude/settings.json`.
- No-op if `stop_hook_active` is true (prevents loops) or no tracked/untracked source changed since the last green run (fingerprint in gitignored `.claude/.last-green`).
- Runs `check.sh fast` always on change; `check.sh full` unless the **red-step marker** `.claude/red-step` exists (created by `tdd` during red, removed on green).
- On failure, exit 2 with: what failed, where, and "fix it, or say 'this is a red step' if you're mid-TDD".
- Red-step marker is visible: session-end reports it, the verifier flags it, pre-push refuses it.

### C5. Secrets & blast radius (D-005)
- `sandbox.enabled: true` with `sandbox.credentials` / `filesystem.denyRead` for `.env*` — OS-level block for every shell command.
- Per-preset `network.allowedDomains` (github.com + PyPI or npm registries) to cut prompts; unlisted hosts prompt (repo-level `strictAllowlist` has no effect).
- Permission **allowlist** for safe commands (check.sh, git status/diff/log, gh pr view) to kill approval fatigue.
- Guard hook (PreToolUse/Bash) blocking obvious `.env` reads and edits under `.github/rulesets/` — documented as an accident guard and the fallback where the sandbox can't run (native Windows, WSL1, missing bubblewrap).

### C6. Merge floor (D-009)
`scripts/git-hooks/pre-push`, enabled by `init.sh` via `core.hooksPath`: refuses direct pushes to main, runs `check.sh full`, refuses if the red-step marker exists. Override: `git push --no-verify` (documented; it is the escape hatch). Rulesets remain the real gate where the plan allows.

### C7. Doctor
`scripts/doctor.sh` (and `/doctor` command wrapping it); `/session-start` runs it first. Plain-English PASS/WARN/FAIL with the exact fix per line:
git + gh auth · preset toolchain · lockfile present · owned skills present · Superpowers/Ponytail installed at pinned versions · hooks executable · settings JSON valid · sandbox available (or "running unprotected" + why) · repo visibility/plan → rulesets applicable and applied, else "main is protected only by your local pre-push hook" · red-step marker absent.

### C8. Verifier upgrade
Input: diff + linked spec only. Report only correctness, security, and requirement gaps, each with evidence. New checks: every spec acceptance criterion maps to a named test; tests touched in the diff are reviewed, not just run; red-step marker absent; no gate overrides unlogged. Definition of done adds built-in `/security-review`.

### C9. Claude PR review — opt-in, shadow mode (D-006)
`presets/common/claude-review.yml`, copied only if the user opts in at init. `anthropics/claude-code-action`, triggered on owner-authored PRs only (never forks), `--max-turns` cap, least-privilege permissions, token from repo secret. Comments; **not** a required check until the owner promotes it (Anthropic's own shadow-mode pattern).

### C10. Plan gate without new files (D-007)
HARNESS.md rule: *no implementation until the spec and its tickets are approved by the owner.* Mapping: grill notes = intent; `docs/designs/<feature>.md` = spec (with an Intent section and numbered acceptance criteria); tickets = plan; tracker = status. No `features.json`, no separate `intent.md`/`plan.md`. Superpowers `docs/plans/` only for large features.

### C11. Harness smoke tests (D-008)
`tests/harness/run.sh` + template-only CI workflow (`harness-ci.yml`, removed by `init.sh`): `init.sh` non-interactively per preset in a temp copy; settings JSON valid; hooks return expected exit codes on fixture inputs; presets go green on a fresh copy; grep docs for dead skill names.

### C12. Docs
- HARNESS.md rewritten: precedence = user > CLAUDE.md > owned skills > Claude Code built-ins > Superpowers (execution only) > Ponytail (style).
- PLAYBOOK: release & rollback section (`v*` tags, revert-PR rollback, incident → regression test); headless/`/batch` recipe; escaped-bugs line in the session log.
- GUIDE: Public-vs-Private tradeoff stated honestly; one-plugin install; `/doctor` as the first command; Windows → WSL2 for sandbox.
- REPO-SECURITY: remove the false Free-plan fallback; add pre-push floor.
- Superpowers brainstorming conflict: suppress its session-start nudge per-project if supported; otherwise document the override.

## Risks

| Risk | Mitigation |
|---|---|
| Stop hook too slow on big suites | `fast` on every changed turn; `full` only when not in red step; fingerprint skips no-change turns. Tune per project. |
| Red-step marker abused to skip tests | Visible in session-end, verifier, and pre-push refusal. |
| Vendored skills go stale | Deliberate upstream-sync PR; smoke tests guard renames. |
| Sandbox friction → users disable it | Pre-listed domains, allowlist, doctor explains failures. |
| Hooks are bash | Requires Git Bash on native Windows (verify in T-04); doctor checks. |
| Shipping template-maintenance docs to users | This design and its plan double as "why the harness is this way" reference; revisit if clutter complaints arise. |

## Sources

- [The AI-native SDLC playbook](https://claude.com/blog/the-ai-native-sdlc-playbook) · [How Anthropic secures its AI-native SDLC](https://claude.com/blog/how-anthropic-secures-its-ai-native-software-development-lifecycle)
- [Claude Code best practices](https://code.claude.com/docs/en/best-practices) · [Sandboxing](https://code.claude.com/docs/en/sandboxing) · [GitHub Actions](https://code.claude.com/docs/en/github-actions)
- [Effective harnesses for long-running agents](https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents)
- [anthropics/claude-code-action](https://github.com/anthropics/claude-code-action) · [addyosmani/factory](https://github.com/addyosmani/factory) (gates.sh, harness tests) · [humanlayer](https://github.com/humanlayer/humanlayer) (handoff pattern)
- GitHub plan gating: [github/docs gated-features](https://github.com/github/docs/tree/main/data/reusables/gated-features)
- MP churn: [mattpocock/skills CHANGELOG](https://github.com/mattpocock/skills/blob/main/CHANGELOG.md)

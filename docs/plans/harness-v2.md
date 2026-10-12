# Plan: Harness v2

Design: `docs/designs/harness-v2.md` · Branch per slice, PR each · Decisions D-004 – D-009

**Rule for every slice:** write the harness smoke-test case first (red), then the change (green). `tests/harness/run.sh` must pass before the PR. Each slice is independently mergeable.

## Order & slices

| # | Slice | Size | Depends on |
|---|---|---|---|
| T-01 | Harness test runner + template CI | S | — |
| T-02 | Preset fixes: CI green out of the box | S | T-01 |
| T-03 | `scripts/check.sh` single check entry point | S | T-02 |
| T-04 | Stop hook verification gate | M | T-03 |
| T-05 | Sandbox, credential deny, allowlist, guard hook | M | T-01 |
| T-06 | Pre-push merge floor | S | T-03 |
| T-07 | Doctor | M | T-04, T-05, T-06 |
| T-08 | Owned process skills (vendor MP subset) | M | T-01 |
| T-09 | Docs rewrite + dead-name purge | M | T-07, T-08 |
| T-10 | Verifier upgrade + `/security-review` in DoD | S | T-08 |
| T-11 | Opt-in Claude PR review (shadow mode) | S | T-02 |
| T-12 | Owner actions on the template repo | XS | T-01 |

---

### T-01 Harness test runner + template CI
- **Files:** `tests/harness/run.sh`, `.github/workflows/harness-ci.yml` (job name `ci`).
- **Do:** bash runner with `check <name> <cmd>` helper, PASS/FAIL summary, non-zero on any failure. First cases: settings JSON valid; no dead skill names (`to-prd`, `to-issues`, `setup-matt-pocock-skills`) in tracked docs — **expected red until T-09**, mark as known-failing list in the runner.
- **Done when:** runner passes locally and in CI on this repo.

### T-02 Preset fixes
- **Files:** `presets/typescript/{package.json,ci.yml,tsconfig.json,src/smoke.test.ts}`, `presets/python/{ci.yml,tests/test_smoke.py}`, `scripts/init.sh`, `README.md`.
- **Do:** rename script `ci` → `check` (pnpm built-in collision); add strict `tsconfig.json` + one smoke test per preset; init copies them. Remove dead `dot-*` rename steps; replace `cp -n` with an explicit `[ -e ] ||` guard; add `HARNESS_PRESET` env for non-interactive runs; init deletes `harness-ci.yml` and `tests/harness/` from user projects. Fix README "What's inside".
- **Test:** runner runs `init.sh` per preset in a temp copy and asserts expected files; in CI, preset checks go green on the fresh copy.

### T-03 `scripts/check.sh`
- **Files:** `scripts/check.sh`, presets' `ci.yml`, `.claude/commands/run-checks.md`.
- **Do:** `check.sh fast|full`; detects preset (pyproject.toml / package.json); no preset → prints "no toolchain yet" and exits 0. CI and `/run-checks` call it.
- **Test:** fast/full exit codes on a green fixture and a deliberately broken fixture.

### T-04 Stop hook
- **Files:** `.claude/hooks/stop-check.sh`, `.claude/settings.json`, `.gitignore` (`.claude/.last-green`, `.claude/red-step`).
- **Do:** per design C4 — `stop_hook_active` short-circuit; change fingerprint (`git diff HEAD` + untracked list hash); fast always on change, full unless red-step marker; exit 2 with plain-English reason. Verify current Stop-hook input schema and exit-code semantics against the hooks docs before coding.
- **Test:** fixture JSON on stdin → exit 0 (no change), 0 (`stop_hook_active`), 2 (broken fixture), 0 (red-step + failing tests but fast green).

### T-05 Sandbox & guards
- **Files:** `.claude/settings.json`, `.claude/hooks/guard.sh`, `presets/*/sandbox-domains.json` (merged by init).
- **Do:** `sandbox.enabled`; credential/`denyRead` for `.env*` (verify relative-path support in the settings reference); per-preset `network.allowedDomains`; permission allowlist (`Bash(scripts/check.sh:*)`, `Bash(git status:*)`, `Bash(git diff:*)`, `Bash(git log:*)`, `Bash(gh pr view:*)`); guard hook blocks `.env` reads via Bash and edits under `.github/rulesets/`, with a message saying it's an accident guard.
- **Test:** guard hook fixtures (block `cat .env`, allow `cat README.md`, block Edit on ruleset). Manual check on macOS: sandboxed `cat .env` denied.

### T-06 Pre-push floor
- **Files:** `scripts/git-hooks/pre-push`, `scripts/init.sh`.
- **Do:** refuse push to `main`/`master`; run `check.sh full`; refuse if red-step marker; message names `--no-verify` as the escape hatch. Init sets `git config core.hooksPath scripts/git-hooks`.
- **Test:** hook fixtures with simulated stdin refs.

### T-07 Doctor
- **Files:** `scripts/doctor.sh`, `.claude/commands/doctor.md`, `.claude/commands/session-start.md`.
- **Do:** checks listed in design C7. Plan detection via `gh api user --jq .plan.name` + repo visibility; rulesets via `gh api repos/{o}/{r}/rulesets`. Sandbox availability: bubblewrap/socat on Linux/WSL2, unsupported on native Windows. Plugin presence/version: confirm the supported way to list installed plugins before coding. Session-start runs doctor first and stops on FAIL.
- **Test:** runs green on a configured machine; FAIL lines on a temp copy with no preset and no remote.

### T-08 Owned process skills
- **Files:** `.claude/skills/{grill,write-spec,slice-tickets,tdd,diagnose}/SKILL.md`, `THIRD_PARTY.md`, `docs/tickets/README.md`.
- **Do:** copy from `mattpocock/skills@49dd158` (`grill-with-docs`, `to-spec`, `to-tickets`, `tdd`, `diagnosing-bugs` + the shared `grilling` primitive they invoke). Header: source repo, commit, MIT notice. Adapt: `GLOSSARY.md`→`CONTEXT.md`; spec path `docs/designs/<feature>.md` with Intent + numbered acceptance criteria; local tickets `docs/tickets/<feature>/NN-slug.md`; tracker from DECISIONS D-003; remove calls to skills we don't vendor. `tdd` creates/removes `.claude/red-step`.
- **Test:** runner asserts each SKILL.md has valid frontmatter and no references to un-vendored skills.

### T-09 Docs rewrite
- **Files:** `CLAUDE.md`, `docs/HARNESS.md`, `PLAYBOOK.md`, `GUIDE.md`, `README.md`, `KICKOFF-PROMPT.md`, `docs/REPO-SECURITY.md`, `scripts/init.sh` (next-steps text).
- **Do:** per design C12. New skill names everywhere; one-plugin install (+ Ponytail) with pinned versions; `/doctor` first; Public/Private tradeoff; remove false Free-plan fallback; release & rollback section; escaped-bugs line in session log; Superpowers brainstorming suppression (investigate per-project disable; else document). Keep CLAUDE.md under ~90 lines.
- **Test:** dead-name check in the runner flips to green; remove it from the known-failing list.

### T-10 Verifier upgrade
- **Files:** `.claude/agents/verifier.md`, `CLAUDE.md` (DoD), `.claude/commands/session-end.md`.
- **Do:** design C8. Session-end reports red-step marker and gate overrides.
- **Test:** manual — run verifier on a branch with a missing acceptance-criterion test; it must flag it.

### T-11 Opt-in Claude PR review
- **Files:** `presets/common/claude-review.yml`, `scripts/init.sh`, `GUIDE.md`.
- **Do:** design C9. Init asks "Enable AI PR review? (needs an Anthropic token as a repo secret) [y/N]". Condition `github.event.pull_request.author_association == 'OWNER'`; `permissions: contents: read, pull-requests: write`; `--max-turns`; prompt = iron rules + verifier checklist. Check the action's current inputs against its README before writing.
- **Test:** YAML lint in the runner; manual run on a test PR.

### T-12 Owner actions (needs explicit owner approval — outward-facing)
- Apply both rulesets to `meJeppoy/agentic-harness-template` (public → works on Free).
- Enable secret scanning + push protection on the template repo.

## Done for the whole plan

All slices merged · `tests/harness/run.sh` green in CI · a fresh "Use this template" copy passes `/doctor` and goes green per preset · GUIDE.md walked end-to-end once on a clean machine (or clean user account) · plan moved to `docs/plans/done/`.

## Implementation notes (2026-10-11)

Built on `feat/harness-v2`, one commit per slice, one PR (instead of a branch per slice) because every slice touches `tests/harness/run.sh`. Deviations from the design, found while verifying live:

- **Plugins can't be pinned by a consumer.** Claude Code has no user-side version pin. Instead: plugins are declared in project settings (`enabledPlugins`, `extraKnownMarketplaces`) and `/doctor` warns when an installed major differs from the tested one (Superpowers 6.x, Ponytail 4.x).
- **Guard hook is platform-gated.** On macOS/Linux/WSL2 with the sandbox available it exits immediately: its pattern match false-positived on commit messages and grep patterns mentioning `.env`, and the sandbox already enforces the read deny at the OS level (verified: EPERM).
- **Sandbox needs toolchain allowances.** uv and pnpm caches added to `filesystem.allowWrite`; `pnpm install`/`add`/`remove` and `gh` added to `excludedCommands` (pnpm's store lock and Go TLS verification both fail under macOS Seatbelt). In the Claude desktop app session used to build this, `excludedCommands` did not take effect for `gh` — verify in a plain CLI session (open question).
- **No `features.json`, no `/handoff`.** Session-end writes a handoff doc instead (humanlayer pattern).
- **Secret scanning** is unavailable on personal private repos even on Pro (GitHub docs source) — REPO-SECURITY §0 states it.
- **Stop hook loop safety** uses a 3-retry cap per user turn instead of exiting on `stop_hook_active` (which would allow only one retry). Claude Code's own 8-continuation cap is the backstop. The last-green record stores the mode (`full`/`fast`) so closing a red step always forces a full run (verifier finding).
- **Per-preset `sandbox-domains.json` not built**: PyPI and npm registries are in the base allowlist instead — no JSON merging in init.
- **Ruleset edits** are blocked by an `Edit(/.github/rulesets/**)` permission deny rule (native) rather than the guard hook.
- **init.sh does not enable the pre-push hook.** Enabling it before the beginner's first setup push would block that push to main. GUIDE §3.2 enables it right after the push; `/doctor` warns until it's on.
- **AI review trigger** uses `author_association` in OWNER/MEMBER/COLLABORATOR (works for org repos) with `pull-requests: read` + `id-token: write` (the action posts through its GitHub App), per the action's own examples.
- **Pre-push checks the working tree**, not the pushed commits — documented in the hook; CI checks the real commits.
- **Doctor's protection check** reads the rules GitHub actually enforces on the default branch (`/rules/branches/<branch>`) and requires a `pull_request` rule, so disabled or unrelated rulesets don't count.
- **T-12** (rulesets + security settings on the template repo) waits for explicit owner approval.

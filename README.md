# Agentic Engineering Harness

A GitHub template for building software with [Claude Code](https://code.claude.com/docs) as a solo builder: a disciplined, AI-native development workflow where the rules that matter are **enforced by the tooling**, not just written down.

Start a new repository from this template and you get a complete operating system for AI-assisted development: a requirements-first process, automatic quality gates, an OS-level security sandbox, durable project memory, and a health check that tells you exactly what's working.

**Who it's for:** anyone shipping software with Claude Code on their own — experienced engineers who want speed without losing rigor, and people with no coding background who need guardrails they can trust. The [Getting-Started Guide](GUIDE.md) assumes no prior knowledge.

---

## Why it exists

AI coding agents are fast, but on real projects they drift: they forget decisions between sessions, build the wrong thing confidently, say "done" while tests fail, over-engineer, and can touch files they shouldn't. Written instructions alone don't stop this — an agent under a long context will sometimes ignore them.

This harness turns the important instructions into mechanisms, following [Anthropic's AI-native SDLC guidance](https://claude.com/blog/the-ai-native-sdlc-playbook):

| Problem | What the harness does |
|---|---|
| Building the wrong thing | Every change starts with an interview (`/grill`), becomes a spec with numbered acceptance criteria, and **nothing is built until you approve it**. |
| "Done" when it isn't | A Stop hook runs your checks: **Claude cannot finish a turn while tests are failing.** |
| Secrets leaking | An OS-level sandbox **blocks reads of `.env` files** for every shell command. |
| Unreviewed code reaching `main` | A local pre-push hook (every plan) and GitHub rulesets (where your plan allows) require PRs with green CI. |
| One reviewer (you) | A verifier subagent checks every acceptance criterion has a test; built-in `/code-review` and `/security-review`; optional AI review on each PR. |
| Forgetting between sessions | Decisions, vocabulary, status and session logs live in versioned files that every session reads. |
| Silent breakage of the setup | `/doctor` checks the whole harness and gives the exact fix for anything missing. |

---

## How it works

```
 you ──► /grill ──► /write-spec ──► /slice-tickets ──► you approve
                                                         │
          ┌──────────────────────────────────────────────┘
          ▼
   per ticket:  tdd  (red → green → refactor)           ◄── Stop hook: can't finish while red
          │                                                  Sandbox: can't read secrets
          ▼
   /code-review · /security-review · verifier            ◄── every acceptance criterion has a test
          │
          ▼
   push branch ──► PR ──► CI green ──► you merge          ◄── pre-push hook + GitHub rulesets
          │
          ▼
   /session-end: ROADMAP, DECISIONS, session log updated  ◄── next session resumes from files
```

| Layer | Lives in | Job |
|---|---|---|
| **Process** | `.claude/skills/` | `grill`, `write-spec`, `slice-tickets`, `tdd`, `diagnose` — owned by your repo, so no upstream change can break them |
| **Gates** | `.claude/hooks/`, `.claude/settings.json`, `scripts/git-hooks/`, CI | Enforce green tests, secret isolation, PR-only `main` |
| **Review** | `.claude/agents/verifier.md`, built-in commands, `presets/common/claude-review.yml` | Adversarial checks against the spec and the project's rules |
| **Memory** | `CONTEXT.md`, `docs/` | Domain vocabulary, decisions, roadmap, specs, tickets, session logs |
| **Plugins** | [Superpowers](https://github.com/obra/superpowers), [Ponytail](https://github.com/DietrichGebert/ponytail) | Isolated worktree + subagent execution for large features; "least code that works" coding style |
| **Health** | `scripts/doctor.sh`, `/doctor` | Plain-English PASS / WARN / FAIL for every part of the setup |

Precedence between these systems, and the full list of what's enforced versus advised, is in [`docs/HARNESS.md`](docs/HARNESS.md).

---

## Requirements

| Tool | Why | Install |
|---|---|---|
| GitHub account | Hosts the repo, runs CI | [github.com/signup](https://github.com/signup) |
| Git | Version control | [git-scm.com](https://git-scm.com/downloads) |
| Claude Code + a Claude plan (Pro/Max) or API key | The AI agent | [code.claude.com/docs](https://code.claude.com/docs) |
| GitHub CLI (`gh`), signed in | Pull requests, tracker sync, protection checks | [cli.github.com](https://cli.github.com) |
| Node.js LTS | Installers; TypeScript projects | [nodejs.org](https://nodejs.org) |
| `uv` *or* `pnpm` | Python *or* TypeScript toolchain (only for the preset you pick) | [uv](https://docs.astral.sh/uv/) · [pnpm](https://pnpm.io/installation) |

**Platforms:** macOS, Linux, and Windows via **WSL2** get full protection. Linux and WSL2 also need `bubblewrap` and `socat` for the sandbox. Native Windows works, but without the sandbox (a weaker guard hook covers `.env` instead) — `/doctor` tells you which you have.

---

## User journey

New to the tools? Follow the [Getting-Started Guide](GUIDE.md) instead — same steps, with every click explained.

### 1. Create your project (5 min)

Click **Use this template** → **Create a new repository**, then clone it.

Choose visibility deliberately — it decides what GitHub can protect for you:

| | Public | Private, GitHub Free | Private, GitHub Pro |
|---|---|---|---|
| Branch protection (PR-only `main`, required CI) | ✅ | ❌ | ✅ |
| Secret scanning + push protection | ✅ free | ❌ | ❌ (organizations: paid add-on) |

On a private Free repo the local pre-push hook is your only merge gate. Details: [`docs/REPO-SECURITY.md`](docs/REPO-SECURITY.md).

### 2. Initialise (5 min)

```bash
./scripts/init.sh
```

It asks for a stack preset (**Python** — uv · ruff · pytest, **TypeScript** — pnpm · biome · vitest, or **none** to decide later), installs it, and asks whether to enable optional AI review on pull requests. It is safe to re-run and never overwrites your files. Then save the setup and switch on the local merge gate:

```bash
git add -A && git commit -m "chore: harness setup" && git push
git config core.hooksPath scripts/git-hooks
```

(The hook blocks direct pushes to `main`, so enable it *after* this first push.)

### 3. Install plugins and verify (5 min)

In Claude Code (`claude`), once per machine:

```
/plugin install superpowers@claude-plugins-official
/plugin marketplace add DietrichGebert/ponytail
/plugin install ponytail@ponytail
```

Restart Claude Code, then run **`/doctor`** and fix every FAIL. WARNs tell you which protections are missing.

### 4. Describe your project (10 min)

Fill the `{{PLACEHOLDERS}}` in [`CLAUDE.md`](CLAUDE.md), record your issue tracker (GitHub Issues, Linear, or local files in `docs/tickets/`) in [`docs/DECISIONS.md`](docs/DECISIONS.md) row D-003, and put your first goal in [`docs/ROADMAP.md`](docs/ROADMAP.md). Shortcut: *"Read CLAUDE.md and interview me to fill every placeholder."*

### 5. Kickoff session (30 min)

Paste the prompt from [`KICKOFF-PROMPT.md`](KICKOFF-PROMPT.md) into Claude Code. It runs four gated stages, stopping for your approval after each: **Orient** (reads the project back to you) → **Verify** (`/doctor`) → **Baseline** (one tiny change through the full workflow, so you see every gate work) → **First grill** (your first real feature becomes an approved spec and tickets).

### 6. Every session

```
/session-start     health check, where you left off, next step, blockers
   … one ticket …
/session-end       decisions, roadmap, tracker, gate audit, session log
```

`/clear` between tickets. If work stops mid-ticket, `/session-end` writes a handoff note that the next `/session-start` resumes from.

### 7. Building a feature

| Step | You type | What happens | Your role |
|---|---|---|---|
| 1 | `/grill` | Relentless interview; domain terms go to `CONTEXT.md`, big decisions to `docs/adr/` | Answer; "I don't know" is fine |
| 2 | `/write-spec` | Spec at `docs/designs/<feature>.md` with numbered acceptance criteria | **Approve it** |
| 3 | `/slice-tickets` | Small vertical slices, each naming the criteria it delivers, published to your tracker | **Approve them** |
| 4 | *"Build ticket 1 with tdd"* | Failing test first, then code until green; refactor | Watch, ask questions |
| 5 | `/code-review`, `/security-review`, *"run the verifier"*, `/ponytail-review` | Correctness, security, criterion → test mapping, over-engineering | Read the plain-English summary |
| 6 | *"Open a PR"* | Branch pushed (pre-push runs checks), PR opened, CI runs, optional AI review comments | **Merge only what you can explain** |
| 7 | `/sync-tracker` | Tracker updated to match what shipped | — |

Large features (multi-day, many files) use Superpowers' isolated worktrees and subagents for step 4, fed by the same approved spec. Hard bugs use the `diagnose` skill: reproduce → minimise → hypothesise → instrument → fix with a regression test.

### 8. Releasing and rolling back

Release by tagging a green `main` (`git tag v1.2.0 && git push origin v1.2.0` — tags are immutable). Roll back with `git revert` through a PR, never by force-pushing. Every production incident becomes a regression test. See [`PLAYBOOK.md`](PLAYBOOK.md) §5.

---

## Commands and skills

| Command | Purpose |
|---|---|
| `/session-start` | Runs `/doctor`, then briefs you: where you left off, next step, blockers |
| `/session-end` | Persists decisions, roadmap, tracker, gate overrides, and a session log |
| `/doctor` | Health check of the whole harness, with fixes |
| `/grill` | Requirements interview; maintains `CONTEXT.md` and ADRs |
| `/write-spec` | Conversation → spec with numbered acceptance criteria |
| `/slice-tickets` | Spec → approved vertical-slice tickets in your tracker |
| `tdd` *(skill)* | Red → green → refactor loop, with the red-step marker |
| `diagnose` *(skill)* | Structured debugging for hard bugs and regressions |
| `/run-checks` | Runs `scripts/check.sh` in a subagent and summarises |
| `/sync-tracker` | Reconciles the tracker with what actually shipped |
| `verifier` *(subagent)* | Adversarial pre-merge review against spec and iron rules |
| `/code-review`, `/security-review` | Built into Claude Code |
| `/ponytail-review`, `/ponytail-audit` | From the Ponytail plugin |

---

## What's enforced

| Rule | Enforced by | Deliberate override (always visible) |
|---|---|---|
| Tests are the contract | Stop hook runs `scripts/check.sh`; up to 3 automatic retries, then hands back to you | `.claude/red-step` during a TDD red step (lint/typecheck still gate); `HARNESS_SKIP_STOP_CHECK=1 claude` for a session |
| No secrets in context | Sandbox `denyRead` on `.env*`; `Read` deny rules; guard hook where the sandbox can't run | You run the command yourself |
| Nothing unchecked reaches `main` | Pre-push hook (blocks `main`, failing checks, open red steps); GitHub rulesets + required `ci` | `git push --no-verify`, recorded in `docs/DECISIONS.md` |
| Ruleset files untouched by Claude | Permission deny rule | You edit them |

Overrides are reported by `/session-end` and flagged by the verifier. A gate that blocks wrongly gets fixed or overridden with a recorded reason — never silently removed.

---

## Repository layout

```
CLAUDE.md               Always-on rules for Claude (fill the placeholders)
CONTEXT.md              Your project's domain vocabulary — built by /grill
GUIDE.md                Zero-to-first-feature walkthrough
PLAYBOOK.md             Operating manual: feature cycle, rituals, releases, context rules
KICKOFF-PROMPT.md       Staged prompt for the first session
THIRD_PARTY.md          Attribution and licenses for adapted material
docs/
  HARNESS.md            Precedence between systems; enforced vs. advised
  REPO-SECURITY.md      GitHub setup: plan table, rulesets, secret scanning, pre-push
  ROADMAP.md            Status — the project's memory between sessions
  DECISIONS.md          Append-only decision log
  INTEGRATIONS.md       External systems and env-var names (never values)
  BACKLOG.md            Parking lot
  adr/ designs/ tickets/ plans/ sessions/
.claude/
  skills/               grill · write-spec · slice-tickets · tdd · diagnose
  hooks/                stop-check.sh (test gate) · guard.sh (.env guard without sandbox)
  agents/               verifier · tracker-sync · integration-prober
  commands/             session-start · session-end · doctor · run-checks · sync-tracker
  settings.json         Sandbox, permissions, hooks, plugin declarations
.github/
  rulesets/             Importable branch and tag protection
  workflows/            Your CI (from the preset); harness-ci.yml is template-only
presets/                python/ · typescript/ · common/claude-review.yml
scripts/                init.sh · check.sh · doctor.sh · git-hooks/pre-push
tests/harness/          The template's own test suite (removed by init.sh)
```

## Configuration

| Variable | Used by | Effect |
|---|---|---|
| `HARNESS_PRESET=python\|typescript\|none` | `init.sh` | Non-interactive preset choice |
| `HARNESS_AI_REVIEW=y\|n` | `init.sh` | Non-interactive AI-review choice |
| `HARNESS_SKIP_INSTALL=1` | `init.sh` | Copy preset files without installing dependencies |
| `HARNESS_SKIP_STOP_CHECK=1` | Stop hook | Disable the test gate for one Claude Code session |
| `HARNESS_GUARD=always` | Guard hook | Force the `.env` guard on even where the sandbox runs |
| `HARNESS_DOCTOR_OFFLINE=1` | `doctor.sh` | Skip checks that call GitHub or Claude Code |

Optional AI pull-request review: run `HARNESS_AI_REVIEW=y ./scripts/init.sh`, then `/install-github-app` in Claude Code to connect GitHub and store the token. It comments only, runs for people with write access, and never blocks merging ([`docs/DECISIONS.md`](docs/DECISIONS.md) D-006).

---

## Known limits

- **Dependable, not foolproof.** The guards stop accidents and common mistakes, not a determined attacker. The sandbox covers shell commands; Claude's file tools are governed by permission rules.
- **Gates are only as good as your tests.** That's why every acceptance criterion needs a named test, and the verifier checks the mapping.
- **The pre-push hook is local**: it checks your working tree, not the exact pushed commits, and `--no-verify` skips it. CI and rulesets are the server-side gate.
- **Plugins aren't version-pinned** (Claude Code has no consumer-side pin). `/doctor` warns when an installed major version differs from the tested one.
- **Some tools can't run inside the macOS sandbox** (`gh`, `pnpm install`); they're excluded from it and Claude asks before running anything else outside it ([`docs/DECISIONS.md`](docs/DECISIONS.md) D-011).

---

## Maintaining this template

The harness tests itself. Before changing anything here:

```bash
tests/harness/run.sh            # fast, offline
tests/harness/run.sh --presets  # also installs and checks both presets (needs uv + pnpm)
```

CI runs the full suite on every pull request (`.github/workflows/harness-ci.yml`). Design and rationale: [`docs/designs/harness-v2.md`](docs/designs/harness-v2.md); decisions D-004 – D-011 in [`docs/DECISIONS.md`](docs/DECISIONS.md). `init.sh` removes the test suite and its workflow from projects created from the template.

## Credits and license

Process skills are adapted from [mattpocock/skills](https://github.com/mattpocock/skills) by Matt Pocock (MIT; see [`THIRD_PARTY.md`](THIRD_PARTY.md)). Plugins: [Superpowers](https://github.com/obra/superpowers) by Jesse Vincent and [Ponytail](https://github.com/DietrichGebert/ponytail) by Dietrich Gebert, both MIT and installed from their own repositories. This template is released under the [MIT License](LICENSE).

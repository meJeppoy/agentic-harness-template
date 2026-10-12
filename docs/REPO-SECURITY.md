# Repo Security Setup

One-time (~20 min), after first push, **before** any bot/App/automation gets write access. `/doctor` tells you which of these are missing.

## 0. Know what your GitHub plan can protect

| Repo | Rulesets / branch protection | Secret scanning push protection |
|---|---|---|
| Public, any plan | ✅ | ✅ free |
| Private, personal account on GitHub Pro | ✅ | ❌ not available |
| Private, organization on Team / Enterprise | ✅ | only with the paid GitHub Secret Protection add-on |
| Private, GitHub **Free** | ❌ not available | ❌ not available |

Source: GitHub's own feature-gating docs ([github/docs `gated-features`](https://github.com/github/docs/tree/main/data/reusables/gated-features)): rulesets *and* classic branch protection are public-repo-only on Free; secret scanning is free on public repos and otherwise needs an organization with Secret Protection. Where push protection isn't available, `.gitignore`, the sandbox, and the `Read` deny rules are your secret nets. On a private Free repo the **local pre-push hook (§5) is your only merge gate**: it blocks direct pushes to main and pushes with failing checks from your machine, but GitHub itself won't stop anything. Choose: make the repo public, upgrade to Pro, or accept that tradeoff knowingly (record it in `docs/DECISIONS.md`).

## 1. Secret protection (first)

Settings → Advanced Security (where your plan has it, see §0): enable **secret scanning** and **push protection** (blocks credential commits before they land — a solo dev's most important net), Dependabot alerts + security updates, private vulnerability reporting. This is layer 3 behind `.gitignore` and the `.claude/settings.json` read-denies.

## 2. Import the rulesets

Settings → Rules → Rulesets → New → **Import a ruleset** → upload both files from `.github/rulesets/`, or:

```bash
gh api repos/<owner>/<repo>/rulesets --method POST --input .github/rulesets/protect-main.json
gh api repos/<owner>/<repo>/rulesets --method POST --input .github/rulesets/protect-release-tags.json
```

`protect-main`: all changes via PR (no direct pushes for anyone — you, bots, agents); required status check **`ci`** with up-to-date branches; review threads resolved; no force-push/deletion; bypass = repo admins only, every bypass logged. `protect-release-tags`: `v*` tags immutable.

**Deliberate choice — 0 required approvals:** GitHub won't let a PR author approve their own PR, so requiring one deadlocks a solo dev, and bot rubber-stamps are theater. Gating comes from CI + `/code-review` + the verifier subagent. **Raise to 1 the day a second human joins.**

**Gotcha:** the required check context `ci` must match your CI job name (both presets use `ci`). A required check that never reports blocks all merges.

**Plan note:** see §0 — on a private repo with GitHub Free, neither rulesets nor classic branch protection are available.

## 3. Actions hardening

Settings → Actions → General: default workflow permissions **read-only** (jobs request write via `permissions:` blocks); "Actions can create PRs" only if automation needs it, "approve PRs" **off, always**; restrict allowed actions and pin third-party actions by SHA; require approval for fork PRs.

## 4. Merge & automation hygiene

Squash merge only (disable merge commits + rebase). Any bot/App gets least privilege — contents/PR/checks write at most, never admin, never on the ruleset bypass list. Secrets via Actions secrets or OIDC; never long-lived keys in CI.

## 5. Local pre-push floor (every plan, every clone)

```bash
git config core.hooksPath scripts/git-hooks
```

`scripts/git-hooks/pre-push` refuses direct pushes to `main`/`master`, pushes with failing `scripts/check.sh full`, and pushes during an open TDD red step. It runs on your machine only, so it's a floor, not a wall: `git push --no-verify` skips it (record why in DECISIONS). Run the command once per clone; `/doctor` warns when it's off.

## 6. Verify (5 min, after CI exists)

Direct push to main → rejected (by the pre-push hook locally, and by the ruleset on GitHub). PR with failing test → merge blocked. Push a fake secret (`AKIA...` pattern in a scratch file) → blocked by push protection (then delete it). `git push --force origin main` → rejected. Record a ✅ in `docs/ROADMAP.md` milestone 0 notes.

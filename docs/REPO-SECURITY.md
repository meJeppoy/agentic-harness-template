# Repo Security Setup

One-time (~20 min), after first push, **before** any bot/App/automation gets write access.

## 1. Secret protection (first)

Settings → Advanced Security: enable **secret scanning** and **push protection** (blocks credential commits before they land — a solo dev's most important net), Dependabot alerts + security updates, private vulnerability reporting. This is layer 3 behind `.gitignore` and the `.claude/settings.json` read-denies.

## 2. Import the rulesets

Settings → Rules → Rulesets → New → **Import a ruleset** → upload both files from `.github/rulesets/`, or:

```bash
gh api repos/<owner>/<repo>/rulesets --method POST --input .github/rulesets/protect-main.json
gh api repos/<owner>/<repo>/rulesets --method POST --input .github/rulesets/protect-release-tags.json
```

`protect-main`: all changes via PR (no direct pushes for anyone — you, bots, agents); required status check **`ci`** with up-to-date branches; review threads resolved; no force-push/deletion; bypass = repo admins only, every bypass logged. `protect-release-tags`: `v*` tags immutable.

**Deliberate choice — 0 required approvals:** GitHub won't let a PR author approve their own PR, so requiring one deadlocks a solo dev, and bot rubber-stamps are theater. Gating comes from CI + `/code-review` + the verifier subagent. **Raise to 1 the day a second human joins.**

**Gotcha:** the required check context `ci` must match your CI job name (both presets use `ci`). A required check that never reports blocks all merges.

**Plan note:** ruleset enforcement on private repos needs a paid plan; on Free, mirror the settings in classic branch protection instead. Public repos: works everywhere.

## 3. Actions hardening

Settings → Actions → General: default workflow permissions **read-only** (jobs request write via `permissions:` blocks); "Actions can create PRs" only if automation needs it, "approve PRs" **off, always**; restrict allowed actions and pin third-party actions by SHA; require approval for fork PRs.

## 4. Merge & automation hygiene

Squash merge only (disable merge commits + rebase). Any bot/App gets least privilege — contents/PR/checks write at most, never admin, never on the ruleset bypass list. Secrets via Actions secrets or OIDC; never long-lived keys in CI.

## 5. Verify (5 min, after CI exists)

Direct push to main → rejected. PR with failing test → merge blocked. Push a fake secret (`AKIA...` pattern in a scratch file) → blocked by push protection (then delete it). `git push --force origin main` → rejected. Record a ✅ in `docs/ROADMAP.md` milestone 0 notes.

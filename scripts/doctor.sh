#!/usr/bin/env bash
# Harness health check: says what works, what's missing, and the exact fix — in plain English.
# Run from anywhere inside the project: scripts/doctor.sh   (or /doctor in Claude Code)
# Exit 1 if anything FAILs. WARN = works, but you're less protected than you could be.
# HARNESS_DOCTOR_OFFLINE=1 skips the checks that call GitHub or Claude Code.
set -uo pipefail
fails=0 warns=0
pass() { echo "PASS  $1"; }
warn() { echo "WARN  $1"; [ -n "${2:-}" ] && echo "      → $2"; warns=$((warns + 1)); }
fail() { echo "FAIL  $1"; [ -n "${2:-}" ] && echo "      → $2"; fails=$((fails + 1)); }
has() { command -v "$1" >/dev/null 2>&1; }
online() { [ -z "${HARNESS_DOCTOR_OFFLINE:-}" ]; }

echo "== Project"
if ! root=$(git rev-parse --show-toplevel 2>/dev/null); then
  fail "Not inside a git repository" "cd into your project folder (the one you cloned), then run this again"
  exit 1
fi
cd "$root" && pass "git repository: $root"

grep -q '{{' CLAUDE.md 2>/dev/null &&
  warn "CLAUDE.md still has $(grep -o '{{[^}]*}}' CLAUDE.md | wc -l | tr -d ' ') unfilled {{placeholder}} values" "ask Claude: \"Read CLAUDE.md and interview me to fill every placeholder\""

echo "== Toolchain"
if [ -f pyproject.toml ]; then
  has uv && pass "python preset: uv $(uv --version 2>/dev/null | cut -d' ' -f2)" || fail "python preset needs uv, which isn't installed" "install it: https://docs.astral.sh/uv/getting-started/installation/"
elif [ -f package.json ]; then
  has node && pass "node $(node --version)" || fail "typescript preset needs Node.js" "install the LTS version from https://nodejs.org"
  has pnpm && pass "pnpm $(pnpm --version 2>/dev/null)" || fail "typescript preset needs pnpm" "install it: https://pnpm.io/installation"
  grep -q '"packageManager"' package.json && pass "package.json pins the pnpm version (packageManager)" ||
    fail "package.json has no \"packageManager\" field, so CI can't tell which pnpm to install and will fail" 'run: pnpm pkg set packageManager=pnpm@$(pnpm --version)'
  [ -f pnpm-lock.yaml ] && pass "pnpm-lock.yaml present" || warn "no pnpm-lock.yaml — CI installs with --frozen-lockfile and will fail" "run: pnpm install, then commit pnpm-lock.yaml"
else
  warn "No stack preset yet (no pyproject.toml or package.json), so there is nothing to test" "fine before your first grill; the kickoff prompt sets up the toolchain"
fi
[ -x scripts/check.sh ] && pass "scripts/check.sh present" || fail "scripts/check.sh is missing or not executable" "restore it from the template, then: chmod +x scripts/check.sh"

echo "== Harness"
missing=0
for s in grill write-spec slice-tickets tdd diagnose; do
  [ -f ".claude/skills/$s/SKILL.md" ] || { fail "process skill '$s' is missing (.claude/skills/$s)" "restore .claude/skills/$s from the template repo"; missing=1; }
done
[ "$missing" -eq 0 ] && pass "process skills: grill, write-spec, slice-tickets, tdd, diagnose"
for h in stop-check guard; do
  [ -f ".claude/hooks/$h.sh" ] && pass "hook: $h" || fail "hook .claude/hooks/$h.sh is missing" "restore it from the template repo"
done
if has python3; then
  python3 -m json.tool .claude/settings.json >/dev/null 2>&1 && pass ".claude/settings.json is valid" || fail ".claude/settings.json is not valid JSON — Claude Code will ignore your hooks and sandbox" "fix the syntax error (python3 -m json.tool .claude/settings.json shows where)"
fi
[ -n "${HARNESS_SKIP_STOP_CHECK:-}" ] && warn "HARNESS_SKIP_STOP_CHECK is set: Claude can finish turns with failing checks" "unset it unless you meant to"
[ -f .claude/red-step ] && warn "A TDD red step is open (.claude/red-step): tests aren't gated and pushes are blocked" "finish the green step, or remove the marker if it was left behind"

if online && has claude; then
  plugins=$(claude plugin list 2>/dev/null)
  for p in "superpowers@claude-plugins-official:6" "ponytail@ponytail:4"; do
    id=${p%:*} tested=${p##*:}
    ver=$(grep -A1 "$id" <<<"$plugins" | sed -n 's/.*Version: //p' | head -1)
    if [ -z "$ver" ]; then warn "plugin ${id%@*} not installed" "in Claude Code: /plugin install $id"
    elif [ "${ver%%.*}" != "$tested" ]; then warn "plugin ${id%@*} $ver — the harness was tested with $tested.x" "it probably works; if anything misbehaves, note it in docs/DECISIONS.md"
    else pass "plugin ${id%@*} $ver"; fi
  done
elif online; then
  warn "Claude Code CLI not found on PATH, so plugins weren't checked" "install: https://code.claude.com/docs"
fi

echo "== Safety nets"
case "$(uname -s)" in
  Darwin) pass "sandbox supported (macOS Seatbelt)" ;;
  Linux)
    if grep -q Microsoft /proc/version 2>/dev/null; then
      warn "WSL1 can't run the sandbox — commands run unprotected (the guard hook still blocks .env access)" "upgrade to WSL2: wsl --set-version <distro> 2"
    elif has bwrap && has socat; then pass "sandbox supported (bubblewrap + socat)"
    else warn "sandbox can't start: bubblewrap/socat missing — commands run unprotected" "sudo apt-get install bubblewrap socat   (Fedora: sudo dnf install bubblewrap socat)"; fi ;;
  *) warn "native Windows can't run the sandbox — commands run unprotected (the guard hook still blocks .env access)" "run Claude Code inside WSL2 for full protection" ;;
esac
[ "$(git config core.hooksPath)" = scripts/git-hooks ] && pass "pre-push floor enabled" ||
  warn "pre-push floor is off: nothing stops a direct push to main from this clone" "git config core.hooksPath scripts/git-hooks"

if online && has gh; then
  if ! login=$(gh api user --jq .login 2>&1); then
    # Inside Claude Code's macOS sandbox, gh (a Go program) can't verify TLS certificates and then
    # wrongly reports the login as invalid. Don't send the user to re-authenticate for that.
    if grep -qiE 'x509|certificate' <<<"$login"; then
      warn "gh can't reach GitHub from inside Claude Code's sandbox (a known macOS limit), so branch protection wasn't checked — your login is fine" "run scripts/doctor.sh in your own terminal, or ask Claude to re-run it outside the sandbox"
    else
      warn "GitHub CLI isn't signed in, so branch protection wasn't checked" "gh auth login"
    fi
  elif repo=$(gh repo view --json nameWithOwner,visibility,owner,defaultBranchRef --jq '"\(.nameWithOwner) \(.visibility) \(.owner.login) \(.defaultBranchRef.name)"' 2>/dev/null); then
    read -r name vis owner branch <<<"$repo"
    # The rules GitHub actually enforces on the default branch (active rulesets only). Protection = PRs required.
    rules=$(gh api "repos/$name/rules/branches/$branch" --jq '[.[].type] | join(" ")' 2>/dev/null)
    plan=$([ "$owner" = "$login" ] && gh api user --jq '.plan.name // ""' 2>/dev/null)
    if [[ " $rules " == *" pull_request "* ]]; then
      pass "$branch on GitHub requires pull requests ($name)"
      [[ " $rules " == *" required_status_checks "* ]] || warn "$branch doesn't require CI to pass before merging" "import .github/rulesets/protect-main.json (docs/REPO-SECURITY.md §2)"
    elif [ "$vis" = PRIVATE ] && [ "$plan" = free ]; then
      warn "$name is private on GitHub Free, which can't protect branches — the pre-push hook is your only merge gate" "make the repo public, or upgrade to GitHub Pro, then follow docs/REPO-SECURITY.md"
    else warn "$branch on $name has no active ruleset requiring pull requests: anyone with access can push straight to it" "follow docs/REPO-SECURITY.md §2 (two gh api commands)"; fi
  else
    warn "no GitHub repository found for this folder" "create one and push: gh repo create --source . --private --push"
  fi
elif online; then
  warn "GitHub CLI (gh) not installed: pull requests, tracker sync and protection checks need it" "install: https://cli.github.com"
fi

echo
echo "$fails failed, $warns warnings"
[ "$fails" -eq 0 ]

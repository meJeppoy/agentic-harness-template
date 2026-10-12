#!/usr/bin/env bash
# Stop hook: Claude can't finish a turn while project checks are red ("tests are the contract").
# - Skips turns where nothing changed since the last green run.
# - TDD red step: while .claude/red-step exists, only lint + typecheck gate (tests are expected to fail).
# - After 3 automatic retries it lets Claude stop and tells you, instead of looping.
# Override for one session: HARNESS_SKIP_STOP_CHECK=1 claude
set -uo pipefail
input=$(cat)
cd "${CLAUDE_PROJECT_DIR:-.}" 2>/dev/null && git rev-parse --git-dir >/dev/null 2>&1 || exit 0

say() { printf '{"systemMessage": "%s"}\n' "$1"; } # shown to the user, not to Claude

if [ -n "${HARNESS_SKIP_STOP_CHECK:-}" ]; then say "Stop check skipped (HARNESS_SKIP_STOP_CHECK is set)."; exit 0; fi

last=.claude/.last-green attempts=.claude/.stop-attempts
grep -q '"stop_hook_active"[[:space:]]*:[[:space:]]*true' <<<"$input" || rm -f "$attempts"

# Fingerprint of the working tree (tracked + untracked, respecting .gitignore), via a throwaway index.
idx=$(mktemp "${TMPDIR:-/tmp}/harness-index.XXXXXX"); cp "$(git rev-parse --git-path index)" "$idx" 2>/dev/null
fp=$(GIT_INDEX_FILE=$idx git add -A 2>/dev/null && GIT_INDEX_FILE=$idx git write-tree); rm -f "$idx"
mode=full; [ -f .claude/red-step ] && mode=fast
# A full green covers both modes; a fast green (red step) never stands in for a full run.
prev=$(cat "$last" 2>/dev/null)
[ -n "$fp" ] && { [ "$prev" = "full $fp" ] || [ "$prev" = "$mode $fp" ]; } && exit 0

if out=$(scripts/check.sh "$mode" 2>&1); then
  echo "$mode $fp" >"$last"; rm -f "$attempts"
  [ "$mode" = fast ] && say "TDD red step active (.claude/red-step): tests are not gated until it's removed."
  exit 0
fi

n=$(($(cat "$attempts" 2>/dev/null || echo 0) + 1))
if [ "$n" -gt 3 ]; then
  rm -f "$attempts"
  say "Checks are still failing after 3 automatic retries. Claude stopped so you can decide what to do — run scripts/check.sh to see why."
  exit 0
fi
echo "$n" >"$attempts"
{
  echo "Project checks are failing, so this turn isn't done (retry $n of 3). Last lines of scripts/check.sh $mode:"
  tail -n 30 <<<"$out"
  echo "Fix the cause; never weaken a test or check. If you are deliberately in the TDD red step, create .claude/red-step and tell the user."
} >&2
exit 2

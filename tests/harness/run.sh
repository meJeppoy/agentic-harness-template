#!/usr/bin/env bash
# Harness smoke tests: deterministic checks that the template itself works.
# Usage: tests/harness/run.sh [--presets]
#   --presets also initialises each stack preset in a temp copy and runs its checks (needs uv + pnpm).
# This folder is template-only: scripts/init.sh deletes it from new projects.
set -uo pipefail
ROOT=$(cd "$(dirname "$0")/../.." && pwd)
FIX="$ROOT/tests/harness/fixtures"
pass=0 fail=0

check() { # check <name> <command...>  — passes when the command exits 0
  local name=$1 out; shift
  if out=$("$@" 2>&1); then
    pass=$((pass + 1)); echo "PASS  $name"
  else
    fail=$((fail + 1)); echo "FAIL  $name"; printf '%s\n' "$out" | tail -n 15 | sed 's/^/      /'
  fi
}

exits() { # exits <code> <command...>  — passes when the command exits with <code>
  local want=$1; shift
  "$@"; local got=$?
  [ "$got" -eq "$want" ] || { echo "expected exit $want, got $got"; return 1; }
}

json_ok() { python3 -m json.tool "$1" >/dev/null; }

# Copy the template (tracked + untracked, minus .git) into a fresh git repo; prints its path.
fresh_copy() {
  local dir; dir=$(mktemp -d)
  (cd "$ROOT" && git ls-files -co --exclude-standard | tar -cf - -T - | tar -xf - -C "$dir")
  (cd "$dir" && git init -q && git add -A && git -c user.name=t -c user.email=t@t commit -qm init)
  echo "$dir"
}

echo "== config"
for f in "$ROOT"/.claude/settings.json "$ROOT"/.github/rulesets/*.json; do
  check "valid JSON: ${f#"$ROOT"/}" json_ok "$f"
done

echo "== scripts"
while IFS= read -r f; do
  check "bash syntax: ${f#"$ROOT"/}" bash -n "$f"
  check "executable: ${f#"$ROOT"/}" test -x "$f"
done < <(cd "$ROOT" && find scripts .claude/hooks tests/harness -type f \( -name '*.sh' -o -path '*/git-hooks/*' \) 2>/dev/null | sed "s|^|$ROOT/|")

echo "== check.sh"
check "no toolchain → exits 0" bash -c "cd '$(mktemp -d)' && '$ROOT/scripts/check.sh' full"

echo "== init + presets"
for p in python typescript none; do
  d=$(fresh_copy)
  check "init ($p) runs non-interactively" env HARNESS_PRESET=$p HARNESS_SKIP_INSTALL=1 HARNESS_AI_REVIEW=n "$d/scripts/init.sh"
  check "init ($p) removes template-only files" test ! -e "$d/tests/harness" -a ! -e "$d/.github/workflows/harness-ci.yml"
  check "init ($p) is safe to re-run" env HARNESS_PRESET=$p HARNESS_SKIP_INSTALL=1 HARNESS_AI_REVIEW=n "$d/scripts/init.sh"
  case $p in
    python) check "init (python) copies preset" test -f "$d/pyproject.toml" -a -f "$d/.github/workflows/ci.yml" -a -f "$d/tests/test_smoke.py" ;;
    typescript) check "init (typescript) copies preset" test -f "$d/package.json" -a -f "$d/tsconfig.json" -a -f "$d/biome.json" -a -f "$d/src/smoke.test.ts" -a -f "$d/.github/workflows/ci.yml" ;;
    none) check "init (none) copies no preset" test ! -e "$d/pyproject.toml" -a ! -e "$d/package.json" ;;
  esac
  if [ "${1:-}" = --presets ] && [ $p != none ]; then
    check "preset ($p) installs" env HARNESS_PRESET=$p HARNESS_AI_REVIEW=n "$d/scripts/init.sh"
    check "preset ($p) is green out of the box" bash -c "cd '$d' && scripts/check.sh full"
    if [ $p = python ]; then broken="$d/tests/test_broken.py"; printf 'def test_broken():\n    assert 1 == 2\n' >"$broken"
    else broken="$d/src/broken.test.ts"; printf 'import { expect, test } from "vitest";\n\ntest("broken", () => {\n\texpect(1).toBe(2);\n});\n' >"$broken"; fi
    check "preset ($p) fast skips tests" bash -c "cd '$d' && scripts/check.sh fast"
    check "preset ($p) full catches a failing test" exits 1 bash -c "cd '$d' && scripts/check.sh full >/dev/null 2>&1"
  fi
  rm -rf "$d"
done

echo
echo "$pass passed, $fail failed"
[ "$fail" -eq 0 ]

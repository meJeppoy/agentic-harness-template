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
  local dir; dir=$(mktemp -d "${TMPDIR:-/tmp}/harness.XXXXXX") && [ -d "$dir" ] || { echo "fresh_copy: cannot create a temp dir" >&2; exit 1; }
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

echo "== owned skills"
for s in grill write-spec slice-tickets tdd diagnose; do
  f="$ROOT/.claude/skills/$s/SKILL.md"
  check "skill $s: frontmatter name matches folder" grep -qx "name: $s" "$f"
  check "skill $s: has a description" grep -q '^description: ..' "$f"
  check "skill $s: credits its upstream source" grep -q 'mattpocock/skills@49dd158' "$f"
done
dead='grill-with-docs|domain-modeling|to-spec|to-tickets|to-prd|to-issues|codebase-design|setup-matt-pocock-skills|GLOSSARY\.md'
check "skills reference no un-vendored skills or files" bash -c "! grep -rnE '/($dead)|\"($dead)\"|\`($dead)\`|$dead' '$ROOT/.claude/skills' | grep -v 'mattpocock/skills@'"

echo "== docs"
# Docs must only point at skills/commands that exist. History files (decisions, the v2 design/plan) are exempt.
gone='to-prd|to-issues|to-spec|to-tickets|grill-with-docs|setup-matt-pocock-skills|/handoff|/triage|/ask-matt|/prototype|/research|/diagnosing-bugs|/improve-codebase-architecture|npx skills'
check "docs reference no removed skills or commands" bash -c "cd '$ROOT' && ! git ls-files -co --exclude-standard -- '*.md' '*.sh' '*.yml' | grep -vE '^(tests/harness/run.sh|docs/DECISIONS.md|docs/designs/harness-v2.md|docs/plans/harness-v2.md|THIRD_PARTY.md|\.claude/skills/)' | xargs grep -nE '$gone'"
for c in session-start session-end doctor run-checks sync-tracker; do
  check "command /$c exists" test -f "$ROOT/.claude/commands/$c.md"
done

echo "== check.sh"
check "no toolchain → exits 0" bash -c "cd '$(mktemp -d "${TMPDIR:-/tmp}/harness.XXXXXX")' && '$ROOT/scripts/check.sh' full"

echo "== stop hook"
d=$(fresh_copy) && fake=$(mktemp -d "${TMPDIR:-/tmp}/harness.XXXXXX") || exit 1
printf '#!/usr/bin/env bash\necho "$1" >>"%s/calls"; [ "$(cat "%s/result")" = pass ] || { echo "1 test failed in app.py"; exit 1; }\n' "$fake" "$fake" >"$d/scripts/check.sh"
stop() { # stop <stop_hook_active> — runs the hook like Claude Code does
  printf '{"hook_event_name":"Stop","stop_hook_active":%s}' "$1" | CLAUDE_PROJECT_DIR="$d" bash "$d/.claude/hooks/stop-check.sh"
}
echo pass >"$fake/result"
check "green checks → allowed to stop" exits 0 stop false
check "no changes since green → checks not re-run" bash -c "n=\$(wc -l <'$fake/calls'); $(declare -f stop); d='$d' stop false; [ \$(wc -l <'$fake/calls') -eq \$n ]"
echo fail >"$fake/result"; echo change >"$d/app.py"
check "failing checks → blocked (exit 2)" exits 2 stop false
check "block message names the failure" bash -c "$(declare -f stop); d='$d' stop false 2>&1 | grep -q 'test failed in app.py'"
check "gives up after 3 automatic retries" bash -c "$(declare -f stop); d='$d'; stop true 2>/dev/null; stop true 2>/dev/null; stop true >/dev/null 2>&1; [ \$? -eq 0 ]"
echo pass >"$fake/result"; touch "$d/.claude/red-step"; echo change2 >>"$d/app.py"
check "red step → only fast checks run" bash -c "$(declare -f stop); d='$d' stop false >/dev/null 2>&1; [ \"\$(tail -n1 '$fake/calls')\" = fast ]"
rm "$d/.claude/red-step"
check "closing a red step forces a full run, even with no other change" bash -c "$(declare -f stop); d='$d' stop false >/dev/null 2>&1; [ \"\$(tail -n1 '$fake/calls')\" = full ]"
echo change3 >>"$d/app.py"
check "HARNESS_SKIP_STOP_CHECK=1 → skipped" bash -c "n=\$(wc -l <'$fake/calls'); $(declare -f stop); d='$d' HARNESS_SKIP_STOP_CHECK=1 stop false >/dev/null; [ \$(wc -l <'$fake/calls') -eq \$n ]"
check "outside a git repo → allowed" exits 0 bash -c "cd '$(mktemp -d "${TMPDIR:-/tmp}/harness.XXXXXX")' && echo '{}' | CLAUDE_PROJECT_DIR=\$PWD bash '$d/.claude/hooks/stop-check.sh'"
rm -rf "$d" "$fake"

echo "== pre-push"
d=$(fresh_copy) && fake=$(mktemp -d "${TMPDIR:-/tmp}/harness.XXXXXX") || exit 1
printf '#!/usr/bin/env bash\n[ "$(cat "%s/result")" = pass ]\n' "$fake" >"$d/scripts/check.sh"
push() { # push <remote branch> — feeds git's pre-push stdin format
  echo "refs/heads/x abc123 refs/heads/$1 def456" | (cd "$d" && bash scripts/git-hooks/pre-push origin git@example.com:o/r.git) >/dev/null 2>&1
}
echo pass >"$fake/result"
check "push to a feature branch with green checks → allowed" exits 0 push feat/x
check "push to main → blocked" exits 1 push main
check "push to master → blocked" exits 1 push master
echo fail >"$fake/result"
check "push with failing checks → blocked" exits 1 push feat/x
echo pass >"$fake/result"; touch "$d/.claude/red-step"
check "push during a TDD red step → blocked" exits 1 push feat/x
rm -rf "$d" "$fake"

echo "== doctor"
d=$(fresh_copy) || exit 1
doc() { (cd "$d" && HARNESS_DOCTOR_OFFLINE=1 bash scripts/doctor.sh 2>&1); }
check "fresh copy has no FAILs" bash -c "$(declare -f doc); d='$d' doc >/dev/null"
check "warns when pre-push floor is off" bash -c "$(declare -f doc); d='$d' doc | grep -q '^WARN.*pre-push'"
git -C "$d" config core.hooksPath scripts/git-hooks
check "passes when pre-push floor is on" bash -c "$(declare -f doc); d='$d' doc | grep -q '^PASS.*pre-push'"
check "warns about unfilled CLAUDE.md placeholders" bash -c "$(declare -f doc); d='$d' doc | grep -q '^WARN.*placeholder'"
touch "$d/.claude/red-step"
check "warns about an open TDD red step" bash -c "$(declare -f doc); d='$d' doc | grep -q '^WARN.*red step'"
cp "$ROOT/presets/typescript/package.json" "$d/package.json"
check "fails when the typescript preset has no packageManager (CI can't pick a pnpm version)" bash -c "$(declare -f doc); d='$d' doc | grep -q '^FAIL.*packageManager'"
rm "$d/package.json"
mv "$d/.claude/skills/tdd" "$d/tdd.bak"
check "fails when an owned skill is missing" exits 1 bash -c "$(declare -f doc); d='$d' doc >/dev/null"
check "explains the fix for a missing skill" bash -c "$(declare -f doc); d='$d' doc | grep -A1 '^FAIL.*tdd' | grep -q '→'"
rm -rf "$d"
check "fails outside a git repo" exits 1 bash -c "cd '$(mktemp -d "${TMPDIR:-/tmp}/harness.XXXXXX")' && HARNESS_DOCTOR_OFFLINE=1 bash '$ROOT/scripts/doctor.sh' >/dev/null 2>&1"

# Online GitHub check with a stub gh: a sandbox TLS failure must not be reported as "not signed in".
d=$(fresh_copy) && bin=$(mktemp -d "${TMPDIR:-/tmp}/harness.XXXXXX") || exit 1
printf '#!/usr/bin/env bash\necho "$GH_STUB_ERR" >&2; exit 1\n' >"$bin/gh"; chmod +x "$bin/gh"
printf '#!/usr/bin/env bash\nexit 0\n' >"$bin/claude"; chmod +x "$bin/claude"
gh_doc() { (cd "$d" && PATH="$bin:$PATH" GH_STUB_ERR="$1" bash scripts/doctor.sh 2>&1); }
check "gh TLS error in the sandbox → says sandbox, not 'not signed in'" bash -c "$(declare -f gh_doc); d='$d' bin='$bin'; out=\$(gh_doc 'tls: failed to verify certificate: x509: OSStatus -26276'); grep -q '^WARN.*sandbox' <<<\"\$out\" && ! grep -q 'signed in' <<<\"\$out\""
check "gh genuinely signed out → says sign in" bash -c "$(declare -f gh_doc); d='$d' bin='$bin'; gh_doc 'HTTP 401: Bad credentials' | grep -A1 '^WARN.*signed in' | grep -q 'gh auth login'"
rm -rf "$d" "$bin"

echo "== guard hook"
guard() { # guard <bash command> — runs the PreToolUse hook on a Bash call
  python3 -c 'import json,sys; print(json.dumps({"hook_event_name":"PreToolUse","tool_name":"Bash","tool_input":{"command":sys.argv[1],"description":sys.argv[2]}}))' "$1" "${2:-run it}" |
    HARNESS_GUARD=always bash "$ROOT/.claude/hooks/guard.sh" 2>/dev/null
}
for c in 'cat .env' 'echo $(< .env)' 'head -5 config/.env.local' "python -c \"print(open('.env').read())\"" 'source .env && npm start'; do
  check "guard blocks: $c" exits 2 guard "$c"
done
for c in 'cat README.md' 'grep -r process.env src' 'source .venv/bin/activate' 'cat .env.example' 'ls -la'; do
  check "guard allows: $c" exits 0 guard "$c"
done
check "guard ignores .env mentioned only in the description" exits 0 guard 'ls' 'check the .env file exists'

echo "== settings"
check "sandbox enabled" python3 -c 'import json,sys; s=json.load(open(sys.argv[1])); assert s["sandbox"]["enabled"] is True' "$ROOT/.claude/settings.json"
check "sandbox denies .env reads" python3 -c 'import json,sys; s=json.load(open(sys.argv[1])); assert "./.env" in s["sandbox"]["filesystem"]["denyRead"]' "$ROOT/.claude/settings.json"
check "guard hook registered" grep -q 'guard.sh' "$ROOT/.claude/settings.json"

echo "== init + presets"
for p in python typescript none; do
  d=$(fresh_copy) || exit 1
  check "init ($p) runs non-interactively" env HARNESS_PRESET=$p HARNESS_SKIP_INSTALL=1 HARNESS_AI_REVIEW=n "$d/scripts/init.sh"
  check "init ($p) removes template-only files" test ! -e "$d/tests/harness" -a ! -e "$d/.github/workflows/harness-ci.yml"
  mkdir -p "$d/tests/harness" && echo mine >"$d/tests/harness/user-file.txt"
  check "init ($p) is safe to re-run" env HARNESS_PRESET=$p HARNESS_SKIP_INSTALL=1 HARNESS_AI_REVIEW=n "$d/scripts/init.sh"
  check "init ($p) re-run keeps the user's own tests/harness" test -f "$d/tests/harness/user-file.txt"
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
d=$(fresh_copy) || exit 1
check "AI review is off unless opted in" bash -c "HARNESS_PRESET=none HARNESS_AI_REVIEW=n '$d/scripts/init.sh' >/dev/null && test ! -e '$d/.github/workflows/claude-review.yml'"
check "init with HARNESS_AI_REVIEW=y installs AI review" bash -c "HARNESS_PRESET=none HARNESS_AI_REVIEW=y '$d/scripts/init.sh' >/dev/null && test -f '$d/.github/workflows/claude-review.yml'"
check "AI review only runs on PRs from people with write access" grep -q 'fromJSON(.\["OWNER","MEMBER","COLLABORATOR"\]' "$ROOT/presets/common/claude-review.yml"
check "AI review is read-only on contents" grep -q 'contents: read' "$ROOT/presets/common/claude-review.yml"
rm -rf "$d"

echo
echo "$pass passed, $fail failed"
[ "$fail" -eq 0 ]

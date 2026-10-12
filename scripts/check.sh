#!/usr/bin/env bash
# The one place project checks are defined. Used by the Stop hook, /run-checks, pre-push, and CI.
#   scripts/check.sh fast   lint + typecheck
#   scripts/check.sh full   fast + tests (default)
set -uo pipefail
mode=${1:-full}
cd "$(dirname "$0")/.."

run() {
  echo "→ $*"
  "$@" || { echo "✗ CHECK FAILED: '$*' — see the errors above." >&2; exit 1; }
}

if [ -f pyproject.toml ]; then
  run uv run ruff check .
  run uv run ruff format --check .
  [ "$mode" = fast ] || run uv run pytest
elif [ -f package.json ]; then
  run pnpm run lint
  run pnpm run typecheck
  [ "$mode" = fast ] || run pnpm run test
else
  echo "No toolchain yet (no pyproject.toml or package.json) — nothing to check."
  exit 0
fi
echo "✓ All $mode checks passed."

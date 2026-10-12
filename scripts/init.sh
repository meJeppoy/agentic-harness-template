#!/usr/bin/env bash
# Agentic Engineering Harness — one-time project init. Safe to re-run; never overwrites your files.
# Non-interactive use: HARNESS_PRESET=python|typescript|none  HARNESS_AI_REVIEW=y|n  HARNESS_SKIP_INSTALL=1
set -euo pipefail
cd "$(dirname "$0")/.."

echo "== Agentic Harness init =="

# 1. Template-only files (the harness's own tests) don't belong in your project.
#    Only on the first run (harness-ci.yml still present), so a later tests/harness/ of yours is never touched.
if [ -f .github/workflows/harness-ci.yml ]; then
  rm -rf tests/harness .github/workflows/harness-ci.yml
  rmdir tests 2>/dev/null || true
fi

copy() { [ -e "$2" ] || cp "$1" "$2"; }
want_install() { [ -z "${HARNESS_SKIP_INSTALL:-}" ]; }

# 2. Stack preset
choice=${HARNESS_PRESET:-}
if [ -z "$choice" ]; then
  echo ""
  echo "Pick a stack preset: [1] python  [2] typescript  [3] none (decide at first grill)"
  read -r -p "> " choice
fi
mkdir -p .github/workflows
case "$choice" in
  1 | python)
    copy presets/python/pyproject.toml pyproject.toml
    copy presets/python/ci.yml .github/workflows/ci.yml
    mkdir -p tests && copy presets/python/test_smoke.py tests/test_smoke.py
    if want_install; then
      if command -v uv >/dev/null; then uv sync --all-groups
      else echo "! uv not found — install it (https://docs.astral.sh/uv/), then run: uv sync --all-groups"; fi
    fi
    echo "✓ python preset (uv · ruff · pytest)" ;;
  2 | typescript)
    for f in package.json tsconfig.json pnpm-workspace.yaml; do copy "presets/typescript/$f" "$f"; done
    copy presets/typescript/biome.preset.json biome.json # stored under another name so Biome ignores it
    copy presets/typescript/ci.yml .github/workflows/ci.yml
    mkdir -p src && copy presets/typescript/smoke.test.ts src/smoke.test.ts
    if want_install; then
      if command -v pnpm >/dev/null; then
        grep -q '"packageManager"' package.json || pnpm pkg set "packageManager=pnpm@$(pnpm --version)"
        pnpm install
      else echo "! pnpm not found — install it (https://pnpm.io/installation), then run: pnpm install"; fi
    fi
    echo "✓ typescript preset (pnpm · biome · vitest)" ;;
  *) echo "→ no preset; the kickoff prompt will establish the toolchain" ;;
esac

# 3. Optional AI review on pull requests (opt-in: needs an Anthropic token stored as a repo secret)
review=${HARNESS_AI_REVIEW:-}
if [ -z "$review" ] && [ ! -e .github/workflows/claude-review.yml ]; then
  echo ""
  echo "Enable AI review comments on your pull requests? Needs an Anthropic token as a GitHub secret — see GUIDE.md. [y/N]"
  read -r -p "> " review
fi
case "$review" in
  y | Y | yes) copy presets/common/claude-review.yml .github/workflows/claude-review.yml && echo "✓ AI PR review (comments only)" ;;
esac

# 4. What's left for the human
cat <<'EOF'

Next steps:
  1. Commit and push this setup:  git add -A && git commit -m "chore: harness setup" && git push
  2. Start Claude Code (claude) and run /doctor — it checks everything and tells you how to fix what's missing.
  3. Fill every {{PLACEHOLDER}} in CLAUDE.md and docs/DECISIONS.md (or ask Claude to interview you for them).
  4. Paste KICKOFF-PROMPT.md into Claude Code.

EOF
echo "Done."

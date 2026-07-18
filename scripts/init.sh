#!/usr/bin/env bash
# Agentic Engineering Harness — one-time project init
set -euo pipefail
cd "$(dirname "$0")/.."

echo "== Agentic Harness init =="

# 1. Activate hidden folders
[ -d dot-claude ] && mv dot-claude .claude && echo "✓ .claude/"
[ -d dot-github ] && mv dot-github .github && echo "✓ .github/"
[ -f dot-gitignore ] && mv dot-gitignore .gitignore && echo "✓ .gitignore"

# 2. Stack preset
echo ""
echo "Pick a stack preset: [1] python  [2] typescript  [3] none (decide at first grill)"
read -r -p "> " choice
mkdir -p .github/workflows
case "${choice:-3}" in
  1) cp -n presets/python/pyproject.toml . && cp -n presets/python/ci.yml .github/workflows/ci.yml
     echo "✓ python preset (uv · ruff · pytest) — see presets/python/README.md";;
  2) cp -n presets/typescript/package.json . && cp -n presets/typescript/ci.yml .github/workflows/ci.yml
     echo "✓ typescript preset (pnpm · biome · vitest) — see presets/typescript/README.md";;
  *) echo "→ no preset; the kickoff prompt will establish the toolchain";;
esac

# 3. What's left for the human
cat <<'EOF'

Next steps (in Claude Code):
  1. /plugin install superpowers@claude-plugins-official
  2. /plugin marketplace add DietrichGebert/ponytail     (then, as a second message:)
     /plugin install ponytail@ponytail
  3. In a terminal: npx skills@latest add mattpocock/skills   (include /setup-matt-pocock-skills)
  4. /setup-matt-pocock-skills   (tracker + labels + docs location)
  5. Fill every {{PLACEHOLDER}} in CLAUDE.md and docs/DECISIONS.md
  6. git add -A && git commit -m "chore: harness scaffold"
  7. Push, then follow docs/REPO-SECURITY.md (rulesets + push protection, ~20 min)
  8. Paste KICKOFF-PROMPT.md into Claude Code

EOF
echo "Done."

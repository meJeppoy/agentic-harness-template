#!/usr/bin/env bash
# PreToolUse guard for Bash: blocks commands that touch .env files (iron rule 1).
# Only active where the sandbox can't run (native Windows, WSL1, Linux without bubblewrap/socat):
# elsewhere the sandbox's denyRead blocks the read at the OS level, and this crude pattern match
# would only add false positives (commit messages, grep patterns, docs).
# It's an accident guard, not a security boundary. HARNESS_GUARD=always forces it on.
set -uo pipefail
input=$(cat)

if [ "${HARNESS_GUARD:-}" != always ]; then
  case "$(uname -s)" in
    Darwin) exit 0 ;;
    Linux) # WSL1 reports "Microsoft" (capital M) and can't sandbox; Linux/WSL2 can if bubblewrap + socat exist.
      if ! grep -q Microsoft /proc/version 2>/dev/null && command -v bwrap >/dev/null && command -v socat >/dev/null; then
        exit 0
      fi ;;
  esac
fi

cmd=$(sed -nE 's/.*"command"[[:space:]]*:[[:space:]]*"(([^"\\]|\\.)*)".*/\1/p' <<<"$input")
cmd=${cmd//.env.example/}; cmd=${cmd//.env.sample/}; cmd=${cmd//.env.template/}
re='(^|[[:space:]/=<>"'"'"'\\])\.env([^A-Za-z0-9_-]|$)'
if [[ $cmd =~ $re ]]; then
  echo "Blocked: this command touches a .env file, which holds secrets (CLAUDE.md iron rule 1). Reference env-var names only. If you truly need it, ask the user to run it themselves." >&2
  exit 2
fi
exit 0

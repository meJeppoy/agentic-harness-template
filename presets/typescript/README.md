# TypeScript preset — pnpm · biome · vitest

`init.sh` copies `package.json` to the repo root and `ci.yml` to `.github/workflows/ci.yml`. Then: `pnpm install`, add a `tsconfig.json` at first grill (strict mode on), code in `src/`, tests alongside as `*.test.ts`. Check command (used by `/run-checks` and CI): `pnpm ci`. The CI job is named `ci` — it must match the required status check in the branch ruleset.

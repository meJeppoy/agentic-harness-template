# TypeScript preset — pnpm · biome · vitest

`init.sh` copies `package.json`, `tsconfig.json` (strict), `pnpm-workspace.yaml` (allows esbuild's install script), `biome.preset.json` → `biome.json`, `ci.yml` → `.github/workflows/ci.yml`, and `smoke.test.ts` → `src/`. It then sets `packageManager` to your installed pnpm version (CI uses it to pick pnpm) and runs `pnpm install`. Commit `pnpm-lock.yaml`: CI installs with `--frozen-lockfile`.

Code in `src/`, tests alongside as `*.test.ts`. Checks run only through `scripts/check.sh` (used by the Stop hook, `/run-checks`, pre-push, and CI): `fast` = `biome check` + `tsc --noEmit`; `full` = fast + `vitest run`. The CI job is named `ci` — it must match the required status check in the branch ruleset.

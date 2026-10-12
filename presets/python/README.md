# Python preset — uv · ruff · pytest

`init.sh` copies `pyproject.toml` to the repo root, `ci.yml` to `.github/workflows/ci.yml`, and `test_smoke.py` to `tests/`, then runs `uv sync --all-groups`. Put code in `src/`, tests in `tests/`.

Checks run only through `scripts/check.sh` (used by the Stop hook, `/run-checks`, pre-push, and CI): `fast` = `ruff check` + `ruff format --check`; `full` = fast + `pytest`. The CI job is named `ci` — it must match the required status check in the branch ruleset.

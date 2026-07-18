# Python preset — uv · ruff · pytest

`init.sh` copies `pyproject.toml` to the repo root and `ci.yml` to `.github/workflows/ci.yml`. Then: `uv sync --all-groups`, put code in `src/`, tests in `tests/`. Check commands (used by `/run-checks` and CI): `uv run ruff check . && uv run ruff format --check . && uv run pytest`. The CI job is named `ci` — it must match the required status check in the branch ruleset.

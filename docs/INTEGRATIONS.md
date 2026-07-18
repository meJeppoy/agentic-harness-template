# Integrations & Credentials Matrix

Every external system the project touches: the env-var names code must use, and current status. Local secrets in `.env` (gitignored); CI secrets in GitHub Actions secrets (or OIDC where supported). Never print or commit values; code references env-var names only.

| System | Purpose | Env vars | CI mechanism | Status |
|---|---|---|---|---|
| _(fill as integrations appear)_ | | | | ⚪ unconfirmed |

Statuses: ⚪ unconfirmed · 🔴 requested · 🟡 in review · ✅ probed working (with date)

## Probe before depending

Before any plan assumes a connection works, run the `integration-prober` subagent against it and record the result here. A failed probe is a tracker comment on whatever blocks it — not a day of mid-feature debugging.

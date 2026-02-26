# Public Release Checklist

Use this checklist before pushing to a public repository.

## Security and Secrets

- Do not commit real credentials, tokens, or private keys.
- Keep only placeholder values in docs.
- Use environment variables for:
  - `APP_API_USERNAME`
  - `APP_API_PASSWORD`
  - `APP_SECURITY_JWT_SECRET`
- Confirm no `.env` files are tracked.

## Large/Generated Files

- Do not track:
  - `web/node_modules/`
  - `spring-api/target/`
  - `.venv/`
  - `.pip-tmp/`
  - `mobile/.dart_tool/`
  - `mobile/build/`
- Model artifacts are currently ignored:
  - `artifacts/*.keras`
  - `artifacts/*.h5`
  - `artifacts/*.json`

## Quick Checks

Run from repo root:

```bash
git status
git ls-files | findstr /I ".env"
git ls-files | findstr /I "node_modules target .venv .dart_tool build"
```

If any generated/secret files appear, untrack them before commit:

```bash
git rm -r --cached <path>
```

## Recommended First Public Commit Scope

- Source code only
- Docs (`README.md`, `docs/`)
- Config templates (`web/.env.example`)
- No personal local IDE/system files

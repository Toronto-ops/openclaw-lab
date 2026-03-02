# scripts

Operational and developer utility scripts live here.

Use this directory for repeatable tasks such as setup, checks, maintenance, and local tooling helpers.

## Guardrail Verification

Run the local guardrail verifier:

```bash
./scripts/verify-guardrails.sh
```

What it checks:
- No `openclaw`/`node` listeners are bound to non-loopback (`0.0.0.0`, `*`, `[::]`).
- Gateway ports `18789`, `18791`, `18792` are LISTEN on `127.0.0.1` or `::1`.
- `gh auth status` succeeds.
- `~/.openclaw/openclaw.json` has these hooks enabled:
  - `token-budget-guard`
  - `image-confirm-guard`
  - `retry-policy-guard`

Exit behavior:
- Returns `0` when all checks pass.
- Returns non-zero when any check fails, with a PASS/FAIL summary.

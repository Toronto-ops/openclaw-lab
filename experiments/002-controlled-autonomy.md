# Experiment 002 — Controlled Autonomy (Local-first)

## Objective
Increase operator autonomy for local work while preserving explicit approval gates for remote/stateful actions.

## Changes Made
- Added `scripts/verify-guardrails.sh` to validate local guardrail posture:
  - non-loopback listener detection for `openclaw`/`node`
  - gateway port loopback binding checks (`18789`, `18791`, `18792`)
  - `gh auth status` verification
  - hook enablement checks for:
    - `token-budget-guard`
    - `image-confirm-guard`
    - `retry-policy-guard`
    - nested config support path: `hooks.internal.entries.<hook>.enabled`
- Updated `scripts/README.md` with usage and behavior documentation for the verifier.

## Evidence
Verifier run summary:
- PASS: 6
- FAIL: 0
- RESULT: PASS

## Safety Outcomes
- No push executed without explicit confirmation.
- Work performed on branch `experiment-002` (local-first flow).

## Status
Ready for PR (not pushed yet).

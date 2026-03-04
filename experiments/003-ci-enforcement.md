# Experiment 003 — CI Enforcement (Guardrails)

## Objective
Enforce guardrail verification in CI and require it for merges into `main`.

## Changes Made
- Added/updated GitHub Actions workflow: `.github/workflows/guardrails.yml`
  - Runs `scripts/verify-guardrails.sh --ci` on:
    - `pull_request`
    - `push` to `main`

## Evidence
### 1) CI runs on `main`
Recent runs on `main` show Guardrails workflow executing successfully on pushes:
- PR #7 merge → Guardrails workflow: success
- PR #6 merge → Guardrails workflow: success
- PR #5 merge → Guardrails workflow: success

### 2) Ruleset requires the check
Repository ruleset requires this status check context:
- `verify-guardrails` (GitHub Actions integration id: 15368)

## Safety Outcomes
- Merges into `main` are gated by CI guardrails verification (required status check).
- CI mode supports running verification in a non-interactive environment.

## Status
PASS

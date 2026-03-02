# Architecture Overview

## Components

### 1) OpenClaw TUI
- Primary operator interface for planning, execution, and tool orchestration.
- Runs local commands and coordinates repository workflows.

### 2) OpenClaw Gateway (localhost)
- Local control plane exposing automation/API surfaces.
- Binds to localhost for local-first operation and reduced exposure.

### 3) Runtime Hooks / Guardrails
- Policy checks that intercept risky operations and enforce constraints.
- Current focus:
  - token budget thresholds and hard-stop behavior
  - explicit image-generation confirmation
  - bounded retry policy with backoff
  - explicit confirmation before push/PR/merge

### 4) GitHub CLI Authentication (`gh`)
- Authenticated local CLI session used for issue/PR/repo operations.
- Delegates identity and authorization to GitHub account permissions.

### 5) Repository Workspace
- Local git checkout containing docs, experiments, scripts, and hooks.
- Serves as source of truth for lab artifacts and experiment records.

## Trust Boundaries

### Localhost-Only Control Path
- Prefer localhost-bound services and local execution paths.
- Avoid exposing gateway/control endpoints to public interfaces by default.

### Secret Handling
- Never commit tokens, credentials, or private keys to git.
- Keep secrets in local env/config stores outside repository history.

### Human Confirmation Boundary
- Require explicit user confirmation before:
  - `git push`
  - pull request creation
  - any merge action
- Treat these as permission-sensitive external changes.

### Guardrail Enforcement Boundary
- Hooks must fail safe: deny or pause when policy state is uncertain.
- Retries are capped and observable; no unbounded self-retry loops.

### Auditability
- Prefer actions that leave clear local logs and reproducible outputs.
- Experiments should document assumptions, outcomes, and anomalies.


## Experiment 001 Observations
- Image confirmation guard prevented generation without explicit confirmation; no billing call path was invoked.
- Push confirmation guard prevented automatic `git push` and required explicit user confirmation.
- Remaining validation scope: token-budget threshold triggers, retry-limit/backoff behavior, PR/merge confirmation paths.

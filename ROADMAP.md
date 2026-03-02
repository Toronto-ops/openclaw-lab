# ROADMAP

## Goal
Build a reliable, safe, and strategically useful OpenClaw lab for rapid experimentation and operational hardening.
Keep scope tight: ship small increments, validate quickly, and preserve strong human governance.

## Milestones
1. Establish repository scaffolding, docs, and conventions.
2. Add baseline hooks/guardrails for safety and policy enforcement.
3. Create repeatable scripts for setup, checks, and local workflows.
4. Stand up first end-to-end experiment with measurable success criteria.
5. Review outcomes, capture lessons, and prioritize next iteration.

## Guardrails
- Require explicit confirmation before any push, pull request creation, or merge.
- Enforce session token budgets (soft/hard thresholds with warnings/escalation).
- Require explicit per-request confirmation before image generation.

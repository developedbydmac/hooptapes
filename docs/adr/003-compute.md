# ADR-003: ECS Fargate first, EKS later

- **Status:** Proposed (start Nov 19, finish by Dec 17)
- **Date:** 2026-11-18
- **Deciders:** Daquan McDaniel

## Context

TODO in your own words. Facts to cover:

- The foundation must be live by Dec 20, built in five 2.5-hour Thursday blocks.
- An EKS control plane costs about $70 a month, and a NAT gateway about $30. The budget is $20 a month. (Approximate; verify the current prices.)
- Nearly every SRE posting asks for Kubernetes.

## Options considered

1. **ECS Fargate first:** TODO.
2. **EKS from the start:** TODO.
3. **Lambda on a schedule:** TODO (worth a line, since the poller is a short periodic job).

## Decision

ECS Fargate for the foundation and Core. The alerts service moves to EKS with Helm and Argo CD in Sprint 4, once the pipeline and alarms work.

## Consequences

TODO: what moves later and what that costs, the public subnets with a public IP on the task (no NAT) and the security groups that make that safe, and the fact that ECS stays a valid end state if time runs short.

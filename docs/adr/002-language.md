# ADR-002: Python for the poller and service tooling

- **Status:** Proposed (decided Nov 17; write it up on Nov 19)
- **Date:** 2026-11-17
- **Deciders:** Daquan McDaniel

## Context

TODO in your own words. Facts to cover:

- The poller and every service outside the test suites need one language.
- The Build Guide is written in Python (the worker, the API and pytest).
- The WGU courses use Python.
- Your QA background is in TypeScript (Playwright, used in PayFlow).
- Earlier plans used TypeScript with Fastify.

## Options considered

1. **Python:** TODO pros and cons.
2. **TypeScript:** TODO pros and cons.

## Decision

Python for the poller and all services and tooling outside the tests. TypeScript stays in the QA test suites (Playwright smoke tests).

## Consequences

TODO: two languages in one repo, which CI jobs need which toolchain, and what would make you revisit this.

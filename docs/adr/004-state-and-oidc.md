# ADR-004: Terraform state and GitHub OIDC

- **Status:** Proposed (state half drafted; OIDC half due Dec 3)
- **Date:** 2026-11-18
- **Deciders:** Daquan McDaniel

## Context

Terraform state records every resource HoopTapes creates, along with real IDs and sometimes sensitive values. It has to live somewhere that:

- survives losing a laptop
- the CI pipeline can reach
- keeps old versions for rollback
- stops two runs from writing at the same time

The deploy pipeline also needs AWS access, without storing long-lived AWS keys in GitHub.

## Options considered

### State and locking

1. **S3 bucket and a DynamoDB lock table:** the long-standing pattern, and what most courses still teach, including Kalyan §6. It means one more resource to create, secure and pay for. Since Terraform 1.11, the S3 backend's DynamoDB arguments are deprecated.
2. **S3 bucket with native locking (`use_lockfile = true`):** HashiCorp's current recommendation for the S3 backend. One bucket holds both the state and the lock file, and CI needs S3 permissions only.
3. **HCP Terraform:** managed state, locking and run history. It adds an outside account and moves part of the workflow off AWS.

### CI credentials

TODO (Dec 3): long-lived IAM user keys stored as GitHub secrets, versus GitHub OIDC with a role trusted only for this repo and branch.

## Decision

**State:** option 2.

- `infra/bootstrap` creates one S3 bucket, `hooptapes-tfstate-<account-id>`, with versioning, SSE-S3 encryption and all four public-access blocks on. The bootstrap keeps its own state locally, because the bucket it creates doesn't exist yet when it runs.
- Every other stack uses the S3 backend with `encrypt = true` and `use_lockfile = true`.
- There is no DynamoDB table.

**CI credentials:** TODO (Dec 3).

## Consequences

- One fewer resource, and no deprecation warnings.
- `required_version = ">= 1.11"` in every stack.
- The CI role needs `s3:GetObject`, `s3:PutObject` and `s3:DeleteObject` on the state keys, including the `.tflock` objects, plus `s3:ListBucket` on the bucket.
- A stuck lock is cleared with `terraform force-unlock <id>`. Only run it after confirming no other run is active.
- The bootstrap's local `terraform.tfstate` is git-ignored. Losing it doesn't lose the bucket, but you'd have to import the bucket to manage it again.
- Revisit if the project ever needs a team workflow with run history and policy checks.

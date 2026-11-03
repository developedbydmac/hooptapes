# CLAUDE.md

## Project context

HoopTapes is an unofficial NBA and college-hoops alert and highlight platform, built solo at about 10 hrs/week as an SRE/DevOps capstone. The plan runs twelve two-week sprints, Nov 2, 2026 to Apr 18, 2027. The app stays small so the platform around it can be serious. The goal is a portfolio where I can defend every line in an interview.

**What it does:** ingests live scores and play-by-play on a schedule, detects close games and viral moments with tunable thresholds, renders one 9:16 highlight card per moment (drawn from play data, rendered once, stored in S3), and fans out alerts and post-game packs by push, SES email and optionally SMS, each linking to the official highlights. It also has a free-to-play contest game (no real money) and AI-written pack captions.

**Out of scope, on purpose:** video clips (NBA footage is licensed), real-money features, custom ML models (win probability is a lookup table), and any web front end beyond a landing page.

**Stack:**
- AWS: Terraform, EventBridge Scheduler, Lambda, SQS FIFO, ECS Fargate, EKS with Helm, ECR, ALB, S3 and CloudFront, SES, Secrets Manager
- Supabase (Postgres and auth); Expo/React Native mobile app; TypeScript services
- GitHub Actions with OIDC to AWS, Argo CD; OpenTelemetry, Prometheus, Grafana, CloudWatch; k6, Trivy, Checkov, Playwright

**Repo layout:**
- `infra/`: Terraform
- `services/`: API, ingest, detector, workers, caption service
- `mobile/`: Expo app
- `docs/adr/`: decision records (copy `000-template.md`, number sequentially)

## Rules for Claude Code

### Who writes what
- **You write the app code:** TypeScript services, Dockerfiles, the mobile app, tests.
- **I write the Terraform, CI/CD pipelines, and Kubernetes/Helm files.** Interviewers probe these, so I need to own every line. In those files, explain, review, point me to docs, and answer questions. Don't write whole files unless I explicitly ask, and if I do, walk me through each line.
- Never copy a course project (Decoding DevOps) or a tutorial wholesale into this repo.

### Safety and cost
- Never run `terraform apply` or `destroy`, and never change AWS resources. `fmt`, `validate`, and `plan` are fine.
- The budget is $20/month. Flag anything that adds recurring cost. The NAT gateway (about $30/mo) and the EKS control plane (about $70/mo) are torn down after every session.
- No long-lived AWS keys anywhere. CI uses OIDC; app secrets live in Secrets Manager. Never commit `.env`, `*.tfvars`, or state.
- Least-privilege IAM by default.

### Product guardrails
- Unofficial fan project: no league or team logos, and no copy that implies an official tie.
- Alerts must fire exactly once per game and moment: idempotency via `alerts_sent`, SQS FIFO dedup, and tests against replay fixtures.
- AI may write captions but never decides scoring or detection. Captions must be schema-validated, with a template fallback.
- Keep scope tight. No new features or projects beyond the sprint plan; if something seems worth adding, suggest it, don't build it.

### Workflow
- `main` is protected. Work on a branch and open a PR. Don't commit or push unless I ask.
- Keep changes small and scoped to the request. No drive-by refactors.
- Significant architecture choices get an ADR first. Ask me before deciding.
- Write tests with the code and run them before saying something works.
- Explain any new dependency before adding it.

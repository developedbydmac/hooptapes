# Cost

How HoopTapes keeps AWS spend low. Prices are approximate us-east-1 list prices; verify them at https://aws.amazon.com/pricing before relying on them. Actual monthly spend gets added here, and to the README, once there is any.

## Rules

1. **$20 monthly AWS budget alarm**, set before anything else is created.
2. **No NAT gateway in the foundation** (about $30/month). Tasks run in public subnets with a public IP and tight security groups.
3. **No EKS until Sprint 4** (about $70/month for the control plane). When it arrives, destroy it at the end of every session.
4. **Nightly scale-to-zero** for ECS services.
5. **Prove it's gone:** at the end of every session, run `scripts/audit-aws.sh`. Empty tables mean nothing hourly is left running.

## What costs money

| Resource | Approx. cost | When |
|---|---|---|
| S3 state and snapshot buckets | cents | always (fine to keep) |
| Public IPv4 address on a running task | $0.005/hour each | while tasks run |
| Fargate task, 0.25 vCPU / 0.5 GB | ~$0.012/hour | while tasks run (scaled to zero nightly) |
| CloudWatch logs, metric filter, alarm | cents to ~$0.10/alarm-month | always |
| ECR image storage | ~$0.10/GB-month | always |
| NAT gateway | $0.045/hour (~$33/month) | not in the foundation |
| RDS, ALB | hourly | Core (Dec 21+), destroyed when idle |
| EKS control plane | $0.10/hour (~$73/month) | Sprint 4 only, destroyed every session |

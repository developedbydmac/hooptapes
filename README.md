# HoopTapes

```
 score feed (balldontlie or fake)
            │
   ┌────────▼─────────┐     snapshots     ┌──────────────┐
   │ Poller on ECS    │──────────────────▶│ S3 bucket    │
   │ Fargate (Python) │                   └──────────────┘
   └────────┬─────────┘
            │ structured logs
   ┌────────▼─────────┐   ┌───────────┐   ┌───────────┐
   │ CloudWatch Logs  │──▶│ metric    │──▶│ alarm →   │
   │                  │   │ filter    │   │ SNS email │
   └──────────────────┘   └───────────┘   └───────────┘

 Terraform owns every resource · GitHub Actions builds, scans and deploys through OIDC
```

The foundation: a poller reads NBA scores through a feed adapter and saves snapshots, and an alarm emails when the feed breaks or goes stale.

**What it is:** a free, NBA-only app that will tell a small group of fans what's on tonight, alert them when a game gets close, and send a recap after the last game. It's also a DevOps/SRE capstone, so the platform around the app is the serious part.

**Status:** in development. The foundation is being built now and is not live yet. Only what's listed under Evidence has actually been run.

## SLOs

None yet. The first SLO and `docs/slo.md` arrive with the foundation.

## Cost

The foundation is designed to cost close to nothing while idle: no NAT gateway, no EKS, a $20 monthly AWS budget alarm and a nightly scale-to-zero. Details: [docs/cost.md](docs/cost.md).

## How to rebuild

Coming once the first stack is applied. It will list prerequisites, the exact commands, what you should see, and how to tear it down.

## Decisions

Architecture decision records are in [docs/adr/](docs/adr/):

- [001: live-score feed and sport scope](docs/adr/001-live-score-feed.md)
- [002: language](docs/adr/002-language.md) (draft)
- [003: compute choice](docs/adr/003-compute.md) (draft)
- [004: Terraform state and OIDC](docs/adr/004-state-and-oidc.md) (draft)

## Evidence

Nothing yet. Load-test results, the postmortem and runbooks will be linked here as each exists. The build log is in [docs/build-log/](docs/build-log/).

## Known limits

No alerts, emails or users yet. Those come after the foundation.

## Disclaimer

HoopTapes is an unofficial fan project. It isn't affiliated with, endorsed by, or sponsored by the NBA, any team, player or broadcaster. All trademarks belong to their owners.

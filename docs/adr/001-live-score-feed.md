# ADR-001: Live-score feed and sport scope

- **Status:** Accepted
- **Date:** 2026-11-03
- **Deciders:** Daquan McDaniel

## Context

HoopTapes needs live scores to detect close games and viral moments (win-probability swings, scoring runs, buzzer-beaters) and send alerts. The feed has to:

- be legal to use in a public, non-commercial fan app
- update during live games
- fit a $20/month total budget that also covers AWS
- cover the sport(s) in scope

The plan originally named both NBA and college basketball. NCAA men's basketball has 360+ teams and can have 100+ games in a night; the NBA has 30 teams and about 15 games a night at most.

## Options considered

1. **balldontlie (NBA), free tier**: 5 requests/min. Its games endpoint returns every game's score, period, clock and status in one call and updates live. Terms allow display in a public app with attribution. Play-by-play and live box scores need the GOAT tier ($39.99/mo), which is over budget. The All-Star tier is $9.99/mo per sport at 60 requests/min.
2. **API-Sports**: 100 requests/day per API, with NBA and NCAA basketball as separate products. One game night uses up the daily quota.
3. **SportsDataIO**: the free trial returns scrambled data, and live data is priced for businesses. Its free Replay product is useful for recorded games but can't run in production.
4. **ESPN hidden API or NBA.com live data**: free and detailed, but undocumented or restricted by their terms. Not a defensible base for a public project.
5. **Recorded games only**: no live risk, but it doesn't meet the goal of real users getting live alerts.

## Decision

- **NBA only for v1.** College basketball is a possible second adapter for March Madness (Sprints 10–11), as a stretch goal only.
- **balldontlie free tier** as the live feed, behind a provider adapter interface.
- **Detect moments from score snapshots, not play-by-play.** Poll the games endpoint about every 15 seconds while games are live (4 requests/min, under the 5/min limit) and skip polling when no games are on. Close games, win-probability swings, scoring runs and late lead changes can all be derived from consecutive snapshots of score, period and clock.
- **Record polled snapshots as replay fixtures**, so the replay harness and tests don't depend on any provider.
- Show balldontlie attribution in the app as its terms require.

## Consequences

- No feed cost during development, and the whole $20 budget stays available for AWS.
- One sport means one adapter, one schedule and one set of thresholds to tune.
- Snapshot polling can miss detail between polls (exactly who scored, the final shot of a buzzer-beater). Cards will describe moments from score and clock rather than individual plays.
- The free tier leaves 1 request/min of headroom, so retries are tight. **Revisit before go-live in Sprint 6:** if rate limits or retries cause missed alerts, upgrade to All-Star ($9.99/mo), which uses half the budget.
- A provider change only needs a new adapter, because detection runs on HoopTapes' own snapshot format.

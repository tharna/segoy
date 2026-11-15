---
id: ADR-021
title: The trigger layer is replaceable
state: accepted
created: 2026-11-15
---
# ADR-021: The trigger layer is replaceable

## Context
The M0 spikes found that most limitations sit in the trigger layer (cloud scheduled tasks), not in Claude Code or the skills:
- issue comments do not start tasks;
- agent-made events do not chain;
- hooks do not run with several repos;
- pushing to `main` depends on the model;
- every run starts from a fresh clone;
- there is an hourly minimum interval and per-hour caps;
- the feature is a research preview.

The alternatives were weighed on 2026-11-15:

| Option | What it is | Fixes | Costs |
|---|---|---|---|
| A. Cloud scheduled tasks (current) | Tasks with GitHub, schedule and API triggers; runs on the subscription | — | The limits above; workarounds in ADR-015 to ADR-020 |
| B. Dispatcher | A small serverless function that receives GitHub webhooks and Otak calls and fires cloud tasks through their `/fire` endpoint | Comment triggers, agent chaining (with its own loop guard), "run now" and Ask Roke without per-task tokens on the phone | Holds task tokens and a webhook secret; one component to deploy; the run caps and the hook gap remain |
| C. Own agent server | A server running Claude Code (headless, Agent SDK, or ACP behind an authenticated service); Otak talks to it | All of the above, plus warm repos and SDKs, hooks in every run, live streaming and approvals in Otak | An internet-facing service holding write tokens for the private brain; patching, uptime, backups; billing probably moves to API keys (subscription terms for this use must be checked); ADR-011 (no backend) no longer holds |

## Decision
- Stay with option A for M1–M3.
- Keep the trigger layer thin, so that B or C replace only `tasks/` and the trigger notes. Skills, the protocol, labels and PR conventions stay the same in all three options. This is already principle 2 in architecture §1.
- Skills must not depend on anything only option A provides, beyond the trigger context they are given.

## Consequences
- The workarounds in ADR-015 to ADR-020 are accepted as the price of zero infrastructure.
- Moving to B or C later is a contained change: new trigger notes, possibly relaxed workarounds, and an ADR superseding this one.

## Revisit when
- **Go to B:** the answer label is regularly forgotten and the periodic sweep feels slow, or "run now" and Ask Roke are being built (O3/O5) and a per-task token on the phone is not acceptable.
- **Go to C** (after checking the billing terms): a live Ask Roke or live approvals in Otak are wanted, Android builds are too slow from cold, or the preview's limits or changes get in the way.

# dotfiles

A living repository tracking configuration and infrastructure across every device this household
runs — one directory per box, plus the shared philosophy and runbooks behind the choices made in
each. See [`motivation.md`](motivation.md) for that philosophy.

Research and rationale for the tool choices live in the public, general-purpose
[are-we-lcars-yet open-source guide](https://chasnelson1990.github.io/are-we-lcars-yet/open-source.html) —
this repo is the opinionated, tracked implementation of that guide, not the other way round.

## Layout

| Directory | Device | Status |
| --- | --- | --- |
| [`terminal/`](terminal/) | Framework 13 laptop (Arch Linux) — desktop environment, packages, dev tooling | Running |
| [`core/`](core/) | Framework Desktop compute core (Box 2) — AI inference, agents, home automation hub, shared services | Planned |
| [`router/`](router/) | Network edge / firewall appliance (Box 1) | Planned — hardware not yet chosen |
| [`handheld/`](handheld/) | Fairphone (or similar), open-source ROM | Not yet started |
| [`docs/`](docs/) | Cross-device runbooks (migrations, backups, one-off infra changes) | — |

Each device directory has its own README with device-specific detail.

# Router

**Status:** roadmap only — hardware not yet chosen, deliberately deferred until last.

The network edge (Box 1) — a dedicated firewall/router appliance, kept separate from the compute
core. See the [top-level README](../README.md) for the full "two boxes, not one" rationale and
why this box is being built last, and [`motivation.md`](../motivation.md) for the philosophy
each pick and deviation is measured against.

## Hardware

| Decision | Pick | Status | Why | LCARS source |
| --- | --- | --- | --- | --- |
| Router / firewall appliance (Box 1) | **Not yet chosen** | Deferred (last) | Existing commercial router stays in place while the compute core is built — see the [top-level README's build sequencing](../README.md#build-sequencing-router-last-deliberately); needs ≥2 physical NICs (WAN/LAN) to run OPNsense, candidates to research include dedicated OPNsense-certified appliances (e.g. Netgate, Protectli) or a repurposed small PC | — (LCARS never names one; its architecture virtualizes OPNsense on the shared box instead) |

## Software stack

| Decision | LCARS recommendation | dotfiles pick | Status | Deviation | LCARS source |
| --- | --- | --- | --- | --- | --- |
| Intrusion detection/prevention | OPNsense + Suricata + CrowdSec (layered) | OPNsense + Suricata + CrowdSec, all on this box | Planned | — | [Hostile takeover incidents](https://chasnelson1990.github.io/are-we-lcars-yet/open-source.html#row-hostile-takeover-incidents) |

## Open decisions

- **Router/firewall appliance hardware** — not yet chosen. Needs ≥2 physical NICs; research
  dedicated OPNsense-certified appliances vs. a repurposed small PC.
- Everything above is provisional until this box is actually purchased — treat "Planned" rows as
  intent, not commitment.

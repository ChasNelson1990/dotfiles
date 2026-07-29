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

## Architecture: two boxes, not one

LCARS's own research (Stack 4) assumes everything — router, NAS, AI compute — lives on one
physical machine under Proxmox VE: TrueNAS in a VM with HBA passthrough, OPNsense in a VM with
NIC passthrough, containers in a third VM. This repo deviates from that shape:

```
Box 1: router appliance                Box 2: Framework Desktop (bare metal Arch Linux)
└─ OPNsense (edge firewall/router)      └─ Btrfs, RAID1 mirror (2 drives)
   ├─ Suricata (IDS/IPS)                └─ Docker Compose
   └─ CrowdSec (log-based blocklist)       ├─ Ollama (Qwen3.6-27B, Vulkan backend) + oterm
                                            ├─ Letta + Postgres (agent memory)
                                            ├─ CrewAI (agent orchestration)
                                            ├─ Caddy (reverse proxy)
                                            ├─ Pi-hole (DNS filtering)
                                            ├─ Home Assistant Assist (voice)
                                            └─ Netdata + Uptime Kuma
```

**Deviation:** two physical boxes instead of one trades a small amount of hardware footprint
and cost for meaningfully better resilience — the router keeps working through a crash, reboot,
or troubleshooting session on the AI/NAS box, since its uptime isn't coupled to that workload.
The compute core (`core/`) runs bare-metal Arch Linux directly (no TrueNAS, no hypervisor) — see
[`core/README.md`](core/README.md) for why. LCARS doesn't name a router-appliance hardware pick,
since its own architecture never separates the two — that hardware choice is still open, see
[`router/README.md`](router/README.md).

## Build sequencing: router last, deliberately

The compute core (`core/`) can be built and secured in full ahead of the router (`router/`),
using the existing commercial router as-is in the interim:

- Remote access is Tailscale, which does its own NAT traversal — nothing needs an inbound
  port-forward, so the compute core is never exposed to the internet regardless of which router
  sits in front of it.
- Pi-hole, Proton VPN/Pass, and Caddy (served only over the Tailscale mesh or LAN) are all
  router-agnostic; none of them depend on OPNsense being in place.
- Skipping Suricata/CrowdSec in the interim costs little, since there's nothing internet-facing
  yet for them to be defending.

**The one real gap this leaves open:** LAN segmentation. A commercial router almost certainly
puts the AI/NAS box on the same flat network as every other device in the house, so a
compromised device anywhere on that LAN has direct access to its file shares and Ollama's API.
OPNsense with VLANs is what closes that. Deferring the router doesn't make
this worse than today, though — that flat-LAN exposure already exists before any homelab does;
sequencing the router last just means closing the "exposed to the internet" risk first and the
"flat LAN" risk second, not skipping the second one.

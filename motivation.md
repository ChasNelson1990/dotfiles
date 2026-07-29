# Motivation

Why this repo makes the choices it makes — for the desktop config and packages
([`terminal/`](terminal/)), and for the homelab roadmap ([`core/`](core/), [`router/`](router/)).
Individual decisions cite back to this document instead of re-arguing the reasoning every time.

None of these are absolute rules. Every deviation gets one line explaining the trade-off,
recorded right next to the decision (see the `Deviation` column in
[`core/README.md`](core/README.md)) — the point is that trade-offs are named, not that
they never happen.

## Open source, by default

Prefer open source tools. Closed-source is fine when there's a specific, named reason
(convenience, an already-paid bundle, avoiding a worse lock-in) — but the reason gets written
down next to the choice, not left implicit.

## Privacy-first

Data shouldn't be readable by a third party without a clear, stated reason. When a third party
is unavoidably in the path — Tailscale's coordination plane, Proton's Pass vaults — the bar is
that it's structurally unable to read the data (end-to-end encryption), not that it merely
promises not to look.

## Pro-data-ownership

Hardware in the house is the source of truth. Cloud/SaaS sits on top as a convenience layer,
not as the store of record. This is why the homelab roadmap centers on a compute core the
household actually owns, rather than treating a cloud drive as primary storage.

## Anti-big-tech, not anti-commercial

Paying for software or hardware is fine. What's being avoided specifically is the
surveillance-capitalism default — a business model funded by extracting and monetizing personal
data — even when that option is free or more convenient. Proton (Pass, VPN) is paid and
commercial, and still fits: its business model is subscriptions, not ad targeting.

## Repairability

Favor hardware with swappable parts, published schematics, and real community repair
documentation over sealed, glued, serialized designs. This is why Framework is the default
hardware line for both the existing laptop and the homelab's compute core.

## Environmental sustainability

Repairability's twin: favor choices that extend a device's useful life — upgradeable RAM and
storage, long firmware-support windows — over ones that quietly force replacement.

## Preferred implementation languages

Pro Rust and Python. Supportive of C++. TypeScript for web UIs specifically. This is a soft
preference about which projects to reach for and, eventually, contribute to — not a rule that
overrides everything else, and it applies to userspace applications the household actively
configures or could extend, not to kernel-level infrastructure (a filesystem, a kernel module)
where the language isn't really a choice being made here. Where the best-evidenced tool for a job
is written in something else entirely (Go shows up a lot: Ollama, Caddy, Tailscale, Docker,
CrowdSec), that's a deviation to name, not a reason to reject a well-proven tool for a
worse-fitting one written in a preferred language.

**Reviewed against existing picks (2026-07-23):** Ollama, Caddy, Tailscale, Docker, and CrowdSec
are all Go, and were reviewed against this principle once it was stated rather than left
unexamined. Kept as-is — each was already chosen against real alternatives on its own technical
merits, and no Rust/Python/C++ alternative at comparable maturity was identified for any of them.
Named here as the accepted deviation rather than silently ignored.

## Worked example: Tailscale over Headscale

Recorded in `core/README.md`. Headscale is the purer choice by the data-ownership and
open-source principles above — a self-hosted, fully open-source coordination server with no
third party ever brokering peer discovery. Tailscale's client is open source but its
coordination server is closed SaaS, and NAT-traversal fallback can route through Tailscale's own
relay servers. The trade accepted here: device-to-device traffic is end-to-end WireGuard-encrypted
either way, so the actual privacy exposure of picking Tailscale is small, and it buys meaningfully
lower day-to-day maintenance. That's the shape every deviation in this repo should take — a
named, bounded trade, not a silent one.

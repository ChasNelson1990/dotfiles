# Core

**Status:** roadmap only — no hardware purchased yet.

The compute core (Box 2) — a Framework Desktop running the household's AI inference, agents,
home automation hub, and shared services. See the [top-level README](../README.md) for how this
fits alongside [`router/`](../router/) — including the two-box architecture and why the router is
being built last — and [`motivation.md`](../motivation.md) for the philosophy each pick and
deviation is measured against.

This page is the opinionated, tracked implementation of
[are-we-lcars-yet](https://chasnelson1990.github.io/are-we-lcars-yet/open-source.html) — a
public, generic comparison of open-source home-lab/self-hosted options. That page stays
general-purpose and cites the wider internet; it does not reference this repo. This page does
the opposite: it picks one option per row, tracks whether it's actually running, and cites the
LCARS row that the pick came from.

## Status legend

- **Planned** — decided, not yet built
- **Running** — deployed and in use
- **Not adopting** — considered and rejected, with a reason

## Public repo note

This directory will eventually hold real service config (compose files, proxy config, etc).
Since this repo is public:

- No real credentials, tokens, certs, or keys are committed here, ever.
- Services that need secrets get a `.env.example` template; the real `.env` is
  git-ignored (see `/.gitignore`).
- If a config file needs a real value (hostname, static IP, etc.), prefer an ignored
  override file over hardcoding it in the tracked template.
- The real `.env` files are themselves populated from Proton Pass at deploy time, not
  hand-edited — see [Secrets management](#secrets-management-proton-pass-cli).

## Hardware

| Decision | Pick | Status | Why | LCARS source |
| --- | --- | --- | --- | --- |
| Compute core (Box 2) | **Framework Desktop (Ryzen AI Max+ 395, 128GB)** | Planned — confirmed | Unified-memory APU runs a 27B–70B-class model with no discrete GPU, same vendor as the Framework 13 this repo already targets. Confirmed via a dedicated investigation — see [Compute core hardware validation](#compute-core-hardware-validation) — after TrueNAS's lack of AMD Apps support briefly put this hardware pick in question | [Compute core hardware](https://chasnelson1990.github.io/are-we-lcars-yet/open-source.html#row-compute-core-hardware) |
| Voice satellite(s) | **Home Assistant Voice Preview Edition** | Planned | Official, fully open-source (hardware + firmware) Nabu Casa hardware; beats a DIY ESP32-S3-BOX-3/M5Stack/ReSpeaker+Pi build on mic quality and first-party support without giving up openness — see [Voice satellite hardware](#voice-satellite-hardware-home-assistant-voice-preview-edition). Quantity/room placement still open, doesn't block the stack | — (LCARS doesn't name specific satellite hardware) |
| Home Assistant host | **Not adopting Home Assistant Green** — runs as a Docker container on the compute core instead | Not adopting | All current smart-home devices integrate via cloud APIs (Hive, SmartThings, SimpliSafe), so there's no local Zigbee/Z-Wave/Thread coordinator needing decoupled uptime — see [Smart-home integrations](#smart-home-integrations-cloud-apis-only-no-local-radio-protocol-yet). Revisit if local-radio devices are added later | — |
| UPS | **APC Smart-UPS SMT750I** | Planned | 750VA/230V/UK tower, comfortable headroom over the Framework Desktop's ~180W peak draw; NUT-compatible over USB (`usbhid-ups`) — see [UPS hardware](#ups-hardware-apc-smart-ups-smt750i) | — |

### Compute core hardware validation

TrueNAS Community Edition was the original Box 2 OS pick (see Software stack, below), but its
Apps framework only officially supports NVIDIA/Intel GPUs — AMD is Custom-App/manual-passthrough
only, and unconfirmed on a unified-memory APU specifically. That, plus early findings of a
documented Ollama crash and a GPU-detection regression on this exact chip, put the whole
Framework Desktop pick in question. Two things resolved it:

1. **TrueNAS is dropped for Box 2 entirely** — it runs bare-metal Linux instead (see the
   Software stack table), which sidesteps the TrueNAS-specific AMD gap altogether.
2. **A direct, bias-corrected investigation of Framework's own community forum** (not generic
   web search, which over-samples complaints): of the 25 most recently active threads on
   `community.frame.work`, only 16% touch AI/LLM inference at all — it's a minority use case,
   but every relevant post that names a memory figure is about this exact 128GB config. Across
   an extended sample (~127 posts, Aug 2025–Jul 2026): ~60 positive, ~13 negative, ~54 neutral.
   The concrete complaints (ROCm instability, GPU-detection failures, a VRAM-ceiling bug) all
   date to **August 2025–February 2026** — the chip's first few months — and none recurred in
   the following months. One persistent, non-decreasing trait, not a bug: getting good
   performance takes real tuning; this platform isn't fully plug-and-play the way a mature CUDA
   setup is. Confidence: moderate, not high — AI-specific forum volume is still thin.

**Accepted going in:** Vulkan (not ROCm) is the community-validated backend for this chip —
ROCm support for this GPU architecture isn't in AMD's own production compatibility matrix.
Some manual tuning should be expected as an ongoing trait, not a one-time setup cost.

**Watch item, not a change (2026-07-23):** Framework has teased an AMD Ryzen AI Max+ **PRO** 495
config (192GB unified memory, 40-CU Radeon 8065S) at `frame.work/desktop?tab=192gb-coming-soon`
— no price or date, newsletter signup only. Not adopted: it's a different GPU stepping than the
395/8060S this validation was done against, so none of the ROCm/Vulkan/community-sentiment
findings above transfer automatically — picking it now would mean redoing this whole validation
from zero community data. The 192GB ceiling also doesn't matter for the current model
(Qwen3.6-27B needs ~17–29GB); it would only matter for a future 70B+ model plan. Revisit only if
it ships with a confirmed price and enough independent Linux/Vulkan track record to redo this
validation properly.

**Future plan, not current (2026-07-23):** a move to 70B-class models is expected at some point.
128GB comfortably fits a single 70B model (~40–75GB on disk depending on quantization) alongside
the current 27B model, so no hardware change is needed for this by itself. **Re-verify
70B-specific stability before actually making that jump** — the one concrete crash bug found in
this validation (Ollama SIGSEGV, upstream issue #13873) was specifically triggered loading a 70B
model on this exact chip, which is more directly relevant to a 70B plan than it was when this
validation was scoped to 27B only. Counter-evidence exists too (Framework's own gpt-oss-120b
benchmark claims, forum reports of DeepSeek V4 Flash and Minimax M2.5 running well), so this
isn't a red flag now — just something to specifically re-check with fresh evidence when the jump
is imminent, not something resolved by the general-sentiment audit above.

### Storage filesystem: ZFS vs. Btrfs at 2 drives

Framework Desktop's mainboard takes exactly 2 drives, and the actual load is ~5 connected
devices/tasks at a time — homelab scale, not enterprise. At 2 drives, RAIDZ isn't reachable
(needs 3+ disks) and Btrfs's risky parity modes were never relevant either — both filesystems
would run as a plain mirror, which closes most of the traditional ZFS-over-Btrfs gap. SnapRAID
was ruled out on fit, not closeness: its value is capacity efficiency across *many* data disks,
which evaporates at 2 drives, and its scheduled (not real-time) parity is a poor match for
actively-written data (Postgres, Docker volumes) regardless of drive count.

Between ZFS and Btrfs specifically: Btrfs RAID1 is mainlined (GPL) with no DKMS/kernel-pairing
risk, uses the standard Linux page cache rather than a large dedicated ARC (lighter on RAM
that's shared with Ollama on this unified-memory box), and gives snapshot-rollback-on-root for
free. ZFS still has the more proven track record for sustained database-style write patterns.
**Picked: Btrfs**, RAID1 mirror across both drives — see [OS decision](#os-decision-arch-linux)
for why this and the OS choice were decided together.

### OS decision: Arch Linux

Compared against TrueNAS (rejected — see above), Debian, Ubuntu Server 24.04 LTS + HWE, and
Fedora. The deciding factor: pairing Arch with **Btrfs instead of ZFS** removes the one objection
that would otherwise have ruled Arch out (ZFS's rolling-release/DKMS breakage risk), leaving
Arch's two real advantages intact — full package-manager and config consistency with the
Framework 13 already in this repo, and the freshest possible Mesa/RADV Vulkan drivers for a chip
whose driver support is still actively improving. Ubuntu remained the only candidate with a
directly *confirmed* success story serving large models on this exact chip, and Fedora improved
once paired with Btrfs (its own native filesystem) — but neither carried the ecosystem-consistency
weight Arch does for this household. **Decided (2026-07-23): the consistency + driver-freshness
combination outweighs Ubuntu's proven track record.** Accepted risk: no confirmed success story
yet of this exact workload (Ollama + Vulkan + Qwen3.6-27B) running on Arch specifically — that's
being taken on faith from the chip-level (not distro-level) evidence in the validation above.

### Off-site backup: Borg + Exoscale

Personal files (photos, etc.) live on Proton Drive already — this is only about the compute
core's and laptop's own system/app data (config, Letta's Postgres memory, oterm's chat history,
Home Assistant's config/recorder DB), realistically tens of GB total, not hundreds. Model
weights are deliberately excluded: they're a reproducible download, not irreplaceable data, same
logic as not backing up an installed package.

**Tool: Borg**, not restic or Kopia — Borg is Python (this household's stated language
preference, see `motivation.md`), it's already the tool used for the Framework 13's own backups
(ecosystem consistency), and Borg 2.0 added native S3-compatible backend support, closing the
narrower-transport gap it used to have against restic/Kopia.

**Destination: Exoscale** (Swiss, S3-compatible), not Proton Drive, Backblaze B2, rsync.net,
Storj, or Sia:
- **Proton Drive** — ruled out on technical fit alone, independent of jurisdiction: restic/Borg
  have no native backend for it, the unofficial rclone bridge has a history of breaking and
  being blocked by Proton itself, and Proton's own official CLI is a separate sync tool, not a
  backup-tool backend — using it would mean a fragile two-stage pipeline.
- **Backblaze B2** — cheapest option (~$6.95/TB/month) but every region (US East/West, Canada
  East, EU Central/Amsterdam) sits inside the Fourteen Eyes intelligence-sharing group.
- **rsync.net** — purpose-built for exactly this workflow, but its standard tier has a
  **$10/month minimum** that dominates the cost at this small a backup size.
- **Storj** and **Sia** — decentralized storage nodes genuinely scattered across 100+ countries
  with no single node holding a complete copy, but the *coordinating entity* in both cases is
  US-based (Storj Labs: Atlanta HQ, Cayman Islands-registered entity; Sia Foundation: US
  501(c)(3)) — decentralization at the storage layer doesn't answer the jurisdiction question
  the way it first appears to. Storj also has a $7/month account minimum, more expensive than
  Exoscale at this scale.
- **Exoscale** — Swiss company, data centers specifically in Geneva and Zurich, genuinely
  outside Five/Nine/Fourteen Eyes at every layer (company and infrastructure). At the actual
  ~50GB scale here, the cost premium over B2 is only a few dollars a year (~€0.018/GB/month vs.
  B2's ~$0.0068/GB/month) — a cheap trade for a materially different jurisdiction.

### Voice pipeline: whisper.cpp (Vulkan) + Piper, centralized on the compute core

**Architecture decided first:** STT/TTS run once, centrally, on the compute core, using its GPU —
every terminal device (the voice satellite hardware, HA's mobile app on a phone, a web/Assist
interface, even the laptop) is a thin client that sends audio to Home Assistant's Assist
pipeline and gets text/audio back over the **Wyoming protocol** (a small JSON-over-TCP standard
from the Rhasspy project, built into HA since 2023.5, designed around exactly this
central-service/thin-client split). This mirrors how everything else here already works — Ollama,
Letta, and CrewAI live on the compute core; the laptop's `oterm` is a thin client over Tailscale,
not a second copy of the stack. Audio never leaves the household's own hardware either way (same
Tailscale mesh as everything else), so this doesn't trade away the pro-data-ownership principle —
it's the same "one shared brain" shape, not a new deviation.

**STT: whisper.cpp, not LCARS's named `faster-whisper`.** Decided specifically for Vulkan
consistency with Ollama, after checking whether any alternative actually offers that:
- **faster-whisper**'s backend (CTranslate2) has no official Vulkan or ROCm support — CUDA/CPU
  only; unofficial community ROCm forks exist but reintroduce the exact out-of-tree ROCm risk
  already rejected for Ollama.
- **sherpa-onnx**-based options (Paraformer, Kroko, Qwen3-ASR Wyoming wrappers) run on ONNX
  Runtime, whose only AMD GPU path is ROCm → MIGraphX (the ROCm execution provider was just
  deprecated in favor of MIGraphX) — **ONNX Runtime has no Vulkan execution provider**, it's an
  open feature request, not shipped. Same ROCm-family dependency problem as faster-whisper.
- **Vosk** (Kaldi-based) has no GPU path at all, and noticeably worse accuracy than Whisper
  short of its largest models.
- **whisper.cpp** has a mature, actively-improving Wyoming wrapper
  (`debackerl/wyoming-whisper.cpp`) with Vulkan support via Mesa/RADV — the same driver stack
  Ollama already uses. The only candidate that's actually Vulkan-consistent, not just "an
  alternative."

**TTS: Piper**, staying with LCARS's own pick, sourced from the current upstream. Piper-class
models don't need GPU acceleration at all (that's the point of Piper — real-time on a Raspberry
Pi's CPU), so Vulkan-consistency isn't a live constraint here the way it is for STT. The one
live alternative considered was **Kokoro** (82M params, Apache 2.0, reportedly more natural
voice, community Wyoming wrappers like `nordwestt/kokoro-wyoming`) — **deferred, not adopted**:
Piper is the HA-blessed default with a more mature integration path, and Kokoro can be swapped
in later without touching anything else in the pipeline (Wyoming's whole point is that STT/TTS
engines are interchangeable behind the same protocol).

The original `rhasspy/piper` repo was archived October 2025 (MIT, last release Nov 2023); active
development continues under the Open Home Foundation's `piper1-gpl` fork (GPL-3.0 — a license
change worth naming, still open source). **Install from `piper1-gpl`, not the archived
original.**

**Wake word** runs on the satellite hardware itself, not the compute core — tracked with [voice
satellite hardware](#compute-core-outstanding-implementation-items), still open.

### Voice satellite hardware: Home Assistant Voice Preview Edition

**Picked: Home Assistant Voice Preview Edition (Voice PE)**, Nabu Casa's own official hardware
(~$69/€59), over a DIY build (ESP32-S3-BOX-3, M5Stack Atom Echo, or a Raspberry Pi + ReSpeaker
HAT running `wyoming-satellite`):

- **Fully open source**, not just "runs open firmware" — both the ESP32 and XMOS-chip firmware
  are published on GitHub, and the hardware schematics are published too. Matches
  [`motivation.md`](../motivation.md)'s open-source and repairability principles as directly as
  the DIY options, without the soldering/manual-flashing overhead. Made by the Home Assistant
  project's own commercial arm (Nabu Casa) — paid hardware from a subscription-funded company,
  not an ad-funded one, fitting the anti-big-tech-not-anti-commercial principle the same way
  Proton does.
- **Dual-mic array with proper echo cancellation** (XMOS XU316 chip: echo cancellation, noise
  removal, auto gain control) — the DIY options are mixed here; the cheapest (M5Stack Atom
  Echo, ~$13) is mono-mic only, fine in a quiet room but weak with music/background noise
  running, a realistic condition for a kitchen or living room satellite. ESP32-S3-BOX-3 is the
  closer competitor (on-chip NPU, no-solder setup) but Voice PE is the only one of the three
  with published schematics *and* an official first-party support path.
- **No subscription required.** Talks only to this repo's own compute-core Wyoming services
  (whisper.cpp STT, Piper TTS — see [Voice pipeline](#voice-pipeline-whispercpp-vulkan--piper-centralized-on-the-compute-core));
  Home Assistant Cloud is available as an optional paid accuracy boost, not a requirement.
- **Local wake word out of the box** via `microWakeWord` (on-device, no cloud call): "Okay
  Nabu," "Hey Jarvis," or "Hey Mycroft" ship supported.

**Not yet decided:** how many units and which rooms — a household-layout question, not a
technical one, and doesn't block anything else in the stack.

### Smart-home integrations: cloud APIs only, no local radio protocol yet

Current devices: Hive heating, a Samsung Jet AI Bespoke robot vacuum, and a SimpliSafe alarm
system. Checked each directly rather than assuming they'd all just work:

- **Hive heating** — solid. Home Assistant's official core integration is mature, actively used,
  and supports full multi-zone heating control (including Boost mode). Fully cloud-dependent
  (Hive's own architecture routes through British Gas's servers, no local path exists), but
  that's already true today regardless of Home Assistant — bringing it into HA adds no new
  cloud exposure.
- **Samsung Jet Bot AI / Bespoke vacuum** — weak, and about to cost money. Rides on HA's
  official SmartThings integration, but community reports are consistent: mostly read-only
  sensors, start/stop/dock control is unreliable. Samsung is also ending free SmartThings API
  access in October 2026 — after that, even this limited access needs a paid ~$5/month
  "Personal Plan" subscription from Samsung.
- **SimpliSafe alarm** — fragile. No official public API exists; HA's integration rides
  entirely on a reverse-engineered library (`simplipy`). Recurring pattern of GitHub issues
  around auth/token failures, some closed by maintainers as "not planned" rather than fixed —
  works until SimpliSafe changes something server-side, with no vendor support path.

**Decided: bring all three in as-is**, accepting Hive's cloud dependency, the Jet Bot's
weak/soon-paid support, and SimpliSafe's fragility as named trade-offs rather than blockers.

**Consequence for the protocol question:** none of these three actually use Zigbee, Z-Wave, or
Thread — they're all cloud-API integrations. So **no local radio coordinator is needed for what
exists today**; Zigbee2MQTT/ZHA/Matter-over-Thread only becomes a live question if/when a
genuinely local-protocol device (a smart bulb, sensor, etc.) gets added. Revisit then, not now.

**Consequence for HA's host:** since nothing here needs a dedicated, always-on local coordinator,
there's no resilience case for a separate Home Assistant Green appliance — see the
[Hardware table](#hardware) — HA runs as a container on the compute core like everything else.
Adding Green later, if local-radio devices arrive, doesn't require re-architecting anything: it
just moves the HA Core process to different hardware.

### Secrets management: Proton Pass CLI

**Picked: Proton Pass CLI**, over sops+age or staying with plain hand-edited `.env` files.
Reuses the household's existing Proton Unlimited subscription and its already-chosen password
manager (see [`motivation.md`](../motivation.md), ecosystem-consistency reasoning already used
for Borg) rather than introducing a new, unrelated tool. Open source (GPL-3.0, official
`protonpass/pass-cli` repo), and secrets stay in the same end-to-end-encrypted vault as
everything else in Pass, instead of sitting as plaintext on disk in a `.env` file.

**How it actually runs:** on the compute core's bare-metal Arch host directly — not inside a
container. A dedicated Pass vault holds the homelab secrets (deSEC API token, Exoscale
credentials, Borg repo passphrase, Tailscale auth key), and a **Personal Access Token (PAT)**
scoped to only that vault authenticates non-interactively — no full account login, no keyring
unlock prompt, which is what makes this usable from a systemd unit or startup script on a
headless server. A host-level script uses that PAT to pull secrets and populate the
(already-gitignored) `.env` files, or inject them as environment variables, immediately before
`docker compose up` — Compose already runs directly on this host with no hypervisor in the way,
so there's a natural place for this step.

**Accepted risk:** Proton Pass CLI is still in **beta** (launched November 2025) — its own docs
are thin specifically on headless-server/systemd deployment, so this is somewhat ahead of
well-trodden usage. Accepted rather than falling back to sops+age, on the strength of the
ecosystem-consistency argument above.

### UPS hardware: APC Smart-UPS SMT750I

**Scope, decided first:** clean shutdown only — the compute core (~12W idle, ~100-104W average,
~180W peak, per Phoronix's measured review of this exact config) doesn't need to keep running
through an outage, just enough runtime to let NUT trigger a graceful `shutdown` before the
battery runs out. No requirement to power the router/network gear too.

**Picked: APC Smart-UPS SMT750I** (750VA, 230V, UK tower, IEC C13 outlets), over both a cheaper
Back-UPS-tier unit and a fully open-hardware/DIY alternative:

- **NUT-compatible** over USB (`usbhid-ups` driver), matching the software stack's existing NUT
  pick. 750VA/~500W real capacity gives comfortable headroom over the ~180W peak — sized for
  reliable shutdown-signal timing, not extended runtime.
- **APC over CyberPower**, specifically for shutdown-timing reliability: community reports
  (Netgate forum and others) describe CyberPower units cutting power only milliseconds after
  NUT's shutdown signal — not enough time to actually finish shutting down, which would defeat
  the entire point here. APC's NUT integration has the more mature track record for this exact
  auto-shutdown timing.
- **Smart-UPS over the cheaper Back-UPS / Back-UPS Pro tiers, specifically for repairability.**
  Checked Schneider's own circularity disclosures directly rather than trusting marketing copy:
  BR900MI (Back-UPS Pro) markets a "user-replaceable battery" but its own circularity profile
  explicitly discloses **"Repair: No"** for lifetime extension — a real, disclosed limitation,
  not a stray omission. SMT750I's own page doesn't carry a repairability disclosure either way
  (undocumented, not a "No") — but real board-level PCB/mainboard spare parts for the Smart-UPS
  SMT line are stocked by specialist UK/US UPS-parts traders (`ups-trader.co.uk`, Critical Parts
  Warehouse), which is a genuine repair path beyond a battery swap, unlike the Back-UPS tiers.

**Considered and not adopted, named as a real trade-off:**
- **APC Symmetra (modular UPS)** — genuinely toolless, hot-swappable power/battery/intelligence
  modules with sub-10-minute MTTR — the actual state of the art for UPS repairability. Ruled
  out on fit, not merit: it's a datacenter-class rack system sized for 4-16kVA+, wildly
  oversized and priced for a single ~180W-peak desktop.
- **Fully open-hardware AC UPS/inverter projects** (ESR's Upside project; LibreVerter;
  OwnTech's µVerter under the CERN Open Hardware License) — checked directly rather than assumed
  workable: all three are genuinely early-stage/research efforts, none has reached a finished,
  replicable, buildable-today state (Upside stalled at first-hardware-lightup in 2018; LibreVerter
  has no BOM, PCB files, or documented community builds as of this check).
- **Victron MultiPlus / MultiPlus-II** (inverter + charger + automatic transfer switch, genuinely
  marketed with UPS functionality, <20ms transfer) — the real, mature, closest-to-open option:
  not open hardware itself, but its monitoring software (Venus OS) is partially open source, and
  it has a strong independent-repair/service culture Schneider's consumer tier doesn't. **Not
  adopted**: it's a proper assembly project (inverter/charger unit + a separately-sourced battery
  + wiring/fusing), not a plug-in product — more effort and cost than "clean shutdown only"
  calls for. Named here as the deliberately-passed-over, more-repairable alternative, not a
  silent gap.
- **Open Compute Project (ORV3)** — ruled out on a category mismatch, not just size: its 48V DC
  bus-bar architecture requires OCP-compliant rack hardware and server sleds on both ends: a
  standard AC-input desktop like the Framework Desktop has no way to connect to it at any scale.

### Coding agent: OpenHands

**New item, not originally on the outstanding-items list** — surfaced while scoping the "Agent
framework" (CrewAI) row: the household currently uses Claude Code for real software development
and wants to move that workload onto the compute core instead, hybrid style (~99% local model,
occasional deliberate fallback to a frontier model via API key for the hardest cases). This is a
distinct role from CrewAI's "Agent framework" row below (small daily tasks — scheduling,
drafting, planning, ticket triage) — a coding agent operating directly on this household's own
repos needs real sandboxing, which the daily-task agent doesn't.

**Model already fits this role well:** Qwen3.6-27B (already the compute core's model pick, see
[Software stack](#software-stack) below) scores **77.2% on SWE-bench Verified** — within ~4
points of Claude Opus 4.6 (80.8%) — though the gap widens on the harder SWE-bench Pro benchmark
(53.5% vs. the open-weight leader's 58.4%, and further behind current frontier models there).
Confirms the existing model/hardware pairing is a genuine match for this new use case, not an
afterthought.

**Picked: OpenHands**, over Aider and Goose, against the actual requirements (terminal-first
prioritized, but VS Code too; sandboxing; remote access from a laptop, a Fairphone running an
open-source OS — e/OS, CalyxOS, or LineageOS, no iOS — and secure web access over Tailscale):

- **Sandboxing**: OpenHands runs every session in an isolated Docker container it architecturally
  cannot escape. Aider has no built-in sandbox at all (the community wraps it in Incus/Docker
  themselves as a common pattern, which says a lot). Goose has a real, more active safety story
  (sandbox mode + prompt-injection detection + an "adversary reviewer" watching for unsafe
  actions) — a genuine strength named here, not a reason it lost.
- **Remote access over Tailscale, no third party**: `openhands web --host 0.0.0.0` runs the same
  terminal-UI experience as a self-hosted browser page — sits behind Caddy+Tailscale like
  everything else in this stack. Works identically from any standard mobile browser, which fits
  an open-source-ROM Fairphone (no native app, no Google Play Store dependency) better than a
  platform-specific app ever would.
- **Goose's real gap here**: it had an equivalent `goose web` feature, but it carried a serious
  Cross-Site WebSocket Hijacking vulnerability (no auth + wildcard CORS — any website visited
  while it ran could silently execute shell commands as the user). Fixed within a day of
  disclosure (Nov 2025), then **removed entirely** in v1.25.0 (March 2026) — current Goose has no
  self-hosted web UI at all. Its mobile story (an iOS app, irrelevant here anyway) relies on
  Cloudflare tunneling by default, a real deviation from this household's Tailscale-only, no
  public exposure architecture.
- **Autonomous/background mode**: OpenHands' headless mode plus its GitHub Resolver (label an
  issue, it sandboxes, edits, tests, and opens a PR unattended) is a distinct, useful capability
  neither Aider nor Goose match as directly.
- **Hybrid local/cloud fallback**: model-agnostic across 100+ providers — the 99%-local/1%-
  frontier-via-API-key pattern is a native, first-class use case, not a workaround.

**Not adopted, named as real trade-offs:**
- **Goose** — Rust (a nice unprompted fit with [`motivation.md`](../motivation.md)'s language
  preference) and Linux Foundation-governed, with arguably a more actively protective safety
  story than OpenHands' pure isolation. Lost specifically on the remote-access/mobile
  requirements, not on safety or governance.
- **Aider** — mature, git-native, Apache 2.0, but no sandboxing at all against a household that
  explicitly asked for it.

**Watch item, not a change (2026-07-23):** AMD's **Lemonade** (an AMD-optimized inference server,
not a coding agent — it would sit under any of the above the same way Ollama does) offers NPU
(XDNA) acceleration neither Ollama nor LM Studio use properly. Checked and **not worth switching
to today**: AMD's own Ryzen AI Software SDK doesn't list Strix Halo (STX-H, this exact chip) as a
supported platform on Linux — NPU dispatch is Windows-only here currently, so Lemonade would just
be "another Ollama" on this hardware, minus the NPU benefit that's its whole reason to exist.
Revisit if Linux NPU support for this chip matures (a community project, FastFlowLM, is
attempting this but isn't there yet).

**Distinct, now also decided:** the "Agent framework" row below (**CrewAI**, for small daily
tasks — scheduling, drafting, planning, ticket triage) is a separate decision from this one — see
that row and [AI safety/guardrails](#ai-safetyguardrails-aegis-garak-and-pyrit) for the reasoning.

### AI safety/guardrails: AEGIS, garak, and PyRIT

This splits into two genuinely different problems, not one:

**Runtime tool-call policy enforcement** — the actual mechanism for rules like "never git push
without approval" and "never send local data to a third party without approval" (plain-text
search queries going out are fine; local data leaving is not). **Picked: AEGIS**, over LCARS's
named NeMo Guardrails:

- Sits between the agent and its tools, classifies each call (SQL, file ops, shell commands,
  network requests), and allows/blocks/holds for human approval — a native **CrewAI integration**
  via a `BeforeToolCallHook`, plus a built-in data-exfiltration detection category that maps
  directly onto the household's stated rule. Human-approval queue with a timeout, webhook/Slack
  alerting (a webhook can drive an HA notification to a phone directly), and a cryptographic,
  tamper-evident audit trail (Ed25519-signed, SHA-256 hash-chained) for after-the-fact debugging.
  MIT licensed, self-hosted, no telemetry.
- **Accepted risk:** AEGIS is early-stage — a single maintainer's recently-launched project, not
  yet a proven, widely-adopted tool. Same shape of risk already accepted once for Proton Pass CLI
  (see [Secrets management](#secrets-management-proton-pass-cli)), taken again here for a much
  closer fit to the actual stated rules than the more established alternative offered.
- **NeMo Guardrails** (Apache 2.0, NVIDIA-maintained, CPU-only core, no GPU requirement) was the
  more established option, but it's built for dialog/content safety (jailbreak detection, PII
  redaction) rather than precise tool-call rules — getting an exact "block git push" behavior
  would mean writing custom Colang policy by hand rather than getting it built in. Production
  setups typically pair it with NVIDIA's own NemoGuard classifier models (48GB **NVIDIA** GPU
  memory each) — not usable on this AMD box; the workaround (Meta's LlamaGuard via the existing
  Ollama/Vulkan setup instead) works but is an extra setup step, not the default path. Not
  adopted, named as the real trade-off against AEGIS's better fit and lower maturity.

**Offline red-teaming / auditing** — periodic security testing of the whole agent stack, not
runtime enforcement. **Picked: both garak and PyRIT**, as LCARS names, since they're genuinely
complementary rather than redundant: **garak** (NVIDIA, Apache-licensed) is breadth-first —
19+ automated probe families covering prompt injection, jailbreaks, hallucination, and
package-hallucination attacks. **PyRIT** (Microsoft, open source) is more deliberate — orchestrates
multi-turn adversarial conversations with an attacker model against the target model, judged by a
scoring model, with all state kept in a local DuckDB (fully self-hostable, checkpoint-safe if
interrupted). Both run entirely locally, no cloud dependency, and would be run periodically
against the compute core's actual stack (Ollama + CrewAI + AEGIS) rather than continuously.

### Models and quantization: two models, both at Q8

**Two separate models, not one shared model** — decided after separating the daily-task role
(CrewAI) from the coding-agent role (OpenHands, see
[Coding agent](#coding-agent-openhands)), rather than assuming Qwen3.6-27B would just serve both:

- **Qwen3.6-27B stays for CrewAI** (daily tasks — scheduling, drafting, planning, ticket triage).
  A fully dense model (all 27B parameters active every pass).
- **Qwen3-Coder-Next for OpenHands** — an 80B-total-parameter **Mixture-of-Experts** model with
  only 3B active parameters per token (512 experts, 10 activated + 1 shared), purpose-built for
  coding agents. The MoE trade-off is the opposite of a dense model's: much less *compute* per
  token (faster inference), but the *entire* 80B-parameter pool still needs to be resident in
  memory (rather than the 27B a dense model needs), since routing isn't known in advance.
- **Capacity was never the constraint either way** — even both models loaded simultaneously
  (Ollama supports concurrent residency via `OLLAMA_MAX_LOADED_MODELS`) fits comfortably inside
  128GB unified memory with room to spare. The real trade-off was operational complexity (two
  models to quantize/maintain) against a purpose-built coding model's likely speed/quality edge
  for OpenHands specifically — decided in favour of the two-model split.

**Quantization: Q8_0 for both**, given the same reasoning applies to each:
- **Qwen3.6-27B → Q8_0** (near-lossless, ~27GB). LCARS gives no quantization guidance at all for
  this model despite recommending it for self-hosting — checked independently: general GGUF
  guidance treats Q4_K_M as "the right balance for most people," but that's sized for someone
  fitting a model onto a 24GB consumer GPU. A **Qwen3.6-27B-specific code-generation benchmark**
  found Q4_K_M drops meaningfully more on coding tasks (56% → 51% on one benchmark) than the
  generic ~98%-quality-retention framing suggests — directly relevant given this model's own
  description centers on "agentic coding." With 128GB unified memory, there's no capacity
  pressure forcing a smaller quant, so there's no reason to accept that quality hit.
- **Qwen3-Coder-Next → Q8** (Unsloth Dynamic "UD" variant if available for this model, else
  plain Q8_0). Its own documentation states "Q6 or Q8 is recommended" for production use, and
  its MoE architecture means quantization can be allocated unevenly across experts (shared/
  frequently-used experts get more precision, rarely-used ones compress harder) — Unsloth's
  Dynamic quants exploit exactly this, claiming even a 3-bit UD variant "comes close to BF16
  performance" for this model. Since the UD variant is strictly better quality at the same size
  as a naive quant, it's the better pick within whichever bit-depth is chosen — and again, no
  capacity pressure argues for going any lower than Q8.

**Gap found in LCARS, worth an issue:** no quantization guidance at all for a model it
specifically recommends for self-hosting, and no mention that this model's code-generation
quality is more quantization-sensitive than typical — directly relevant given LCARS's own
description names "agentic coding" as the point of this model.

### Primary interface: oterm + Open WebUI

LCARS's "Primary interface" row actually names three tools, not a single pick: Open WebUI, Home
Assistant Assist (the voice pipeline — already decided separately, see
[Voice pipeline](#voice-pipeline-whispercpp-vulkan--piper-centralized-on-the-compute-core)), and
oterm. It frames Open WebUI and oterm as complementary, not competing: "quick, no-server terminal
access to the same local models" (oterm) alongside "a shared, multi-user chat surface" (Open
WebUI) — both pointing at the same Ollama backend rather than three separate stacks.

**Originally recorded as oterm only** — revisited once this household's actual multi-endpoint
shape was accounted for: oterm is a terminal UI, and the handheld device (`../handheld/`, a
phone) has no terminal surface at all. LCARS itself has no phone-specific AI-chat row — its two
phone-adjacent rows cover messaging (Signal) and hardware (the Fairphone itself), neither of
which touches Ollama access — so the phone case was a genuine gap, not something already covered
elsewhere.

**Decided: both**, following the same reachability pattern already established for OpenHands
(see [Coding agent](#coding-agent-openhands)) — self-hosted, a Docker Compose container on the
core, reached via Caddy + Tailscale, no native app, no Play Store dependency:

- **oterm** stays for the laptop (`../terminal/`) — near-zero setup, matches this household's
  terminal-first workflow, MIT licensed.
- **Open WebUI** covers the phone (`../handheld/`) and browser-based access generally — gets a
  `*.lab.chasnelson.co.uk` hostname (see [Caddy hostname mapping](#caddy-hostname-mapping)),
  the same as every other persistent, browser-facing service in this stack.
- Both point at the same Ollama instance — no duplicate model serving.

**Auth: on.** Open WebUI's own multi-user account system stays enabled rather than running
single-user/no-auth — relevant since more than one household member may use it, even though it's
never reachable outside the tailnet either way.

**Checked, not a blocker:** Open WebUI's 2025 relicensing added a branding-retention clause that
only applies at 50+ active users — irrelevant at household scale.

### Notifications: unified via Home Assistant, across AEGIS, CrewAI, and OpenHands

**Decided:** every "a human needs to look at this" moment across the agent stack routes through
the same channel — Home Assistant's actionable push notifications — rather than each tool
getting its own dashboard or notification path.

**Why this is possible, not just convenient:** CrewAI's open-source layer ships no first-party UI
at all — its HITL (`@human_feedback`) mechanic is webhook-based by design: you provide a webhook
URL and auth strategy when starting a Flow, a human responds with `approved`/`rejected`/
`needs_revision`, and a callback resumes the Flow. The polished dashboard, approval routing, and
analytics all live in CrewAI Enterprise, a separate commercial hosted product, not something
self-hosted. The two community-built open-source CrewAI dashboards found (`crewAI-dashboard`,
`CrewAI-UI`) are both dead — over two years since their last commit, one with zero stars — so
there was never a viable dashboard to adopt here. AEGIS already reaches for the same shape: its
alerting is webhook/Slack-based, and a webhook can drive an HA notification directly (see
[AI safety/guardrails](#ai-safetyguardrails-aegis-garak-and-pyrit)).

HA's own actionable-notification feature is the piece that makes "route it all through HA"
concrete rather than aspirational: the companion app supports up to 3 buttons on Android (~10 on
iOS) plus an optional free-text response, firing an event HA can act on — matching CrewAI's own
`approved`/`rejected`/`needs_revision` vocabulary almost exactly.

**The pipeline:**
- AEGIS holds a tool call for approval → webhook → HA sends an actionable push notification
  (e.g. Approve/Block) → tap fires an HA automation → calls back to AEGIS's approval API.
- CrewAI's `@human_feedback` pauses a Flow → its own webhook → the same HA notification path,
  with buttons matching CrewAI's approve/reject/revise options (plus free-text for a
  `needs_revision` explanation).
- **Goal, not yet built:** OpenHands' async/headless completions (e.g. a GitHub Resolver PR
  ready for review) route through the same channel too — one "something needs you" surface
  across the whole agent stack, not three separately-checked inboxes.

**Deliberately not pursued:** a dedicated CrewAI monitoring dashboard, bespoke or otherwise — the
household doesn't need to *watch* Crews run continuously, only to be interrupted when a decision
is actually needed, which this pipeline already covers.

**Not a factor in the Primary interface pick** (see
[Primary interface](#primary-interface-oterm--open-webui)): both Open WebUI's and AnythingLLM's
own built-in automation/scheduling features were already ruled out in favour of CrewAI to avoid
duplicating it, so neither tool's own notification handling for those specific features is ever
exercised either way. The daily-chat interface is a synchronous, human-at-the-keyboard surface —
a different category of interaction from the background/automation layer this pipeline is for.

### Creating CrewAI tasks: voice and chat, gating only what runs

**Decided:** creating a new CrewAI task — ad hoc or scheduled — isn't itself gated by AEGIS; only
what the task *does* once it runs is. Two creation routes, both reusing pieces already decided
rather than adding anything new, both ultimately calling CrewAI's already-decided API-wrapper
activation route (see the Agent framework row in [Software stack](#software-stack)):

- **Voice, via HA Assist**: a custom sentence trigger (e.g. `ask crew to {request}`) captures
  free text via HA's `{wildcard}` slot syntax and fires it into an automation that calls the
  API-wrapper endpoint — works from the Voice PE speaker or the HA companion app's own Assist
  button on the phone.
- **Typed, via the primary chat interface**: Open WebUI's Tools mechanism (Python
  function-calling that can hit external HTTP APIs) lets an ordinary chat turn — "schedule a
  task to draft my weekly report every Monday" — call the same endpoint.

**Decided: don't gate creation, only execution.** Spinning up a new task is treated as low-risk
— the actual risk sits in what the task does once it's running (file ops, network calls, etc.),
which AEGIS already gates per
[AI safety/guardrails](#ai-safetyguardrails-aegis-garak-and-pyrit). Adding an approval step to
creation itself would slow down the exact "quick, ambient request" use case both routes exist
for, without meaningfully reducing risk — the thing worth interrupting a human for is still
surfaced later via the
[notifications pipeline](#notifications-unified-via-home-assistant-across-aegis-crewai-and-openhands)
if/when the task actually needs a decision.

## Software stack

Picks below start from LCARS's own per-row recommendation. Anything under **Deviation**
overrides that recommendation for a reason specific to this household, not a correction to
the LCARS research.

| Decision | LCARS recommendation | dotfiles pick | Status | Deviation | LCARS source |
| --- | --- | --- | --- | --- | --- |
| NAS / storage OS | TrueNAS Community Edition | **Arch Linux, bare metal** | Planned | TrueNAS's Apps framework has no official AMD GPU support (NVIDIA/Intel only, unconfirmed on this APU) — dropped in favor of direct OS control; Arch chosen for ecosystem consistency with the Framework 13 and freshest Vulkan drivers, see [OS decision](#os-decision-arch-linux) | [Storage medium](https://chasnelson1990.github.io/are-we-lcars-yet/open-source.html#row-storage-medium) |
| Storage redundancy | OpenZFS | **Btrfs, RAID1 mirror** | Planned | Named trade-off, see [Storage filesystem](#storage-filesystem-zfs-vs-btrfs-at-2-drives): at 2 drives both run as a plain mirror, and Btrfs removes ZFS's rolling-release/DKMS risk on Arch specifically while using less RAM headroom shared with Ollama | [Processing redundancy](https://chasnelson1990.github.io/are-we-lcars-yet/open-source.html#row-processing-redundancy) |
| AI inference runtime | Ollama | Ollama, **Vulkan backend** (`OLLAMA_VULKAN=1`) | Planned | Not ROCm — community-validated as the more reliable backend for this chip; ROCm isn't in AMD's production compatibility matrix for this GPU architecture | [Core architecture](https://chasnelson1990.github.io/are-we-lcars-yet/open-source.html#row-core-architecture) |
| Model (daily-task agent) | Qwen3.6-27B | Qwen3.6-27B, **Q8_0** | Planned | LCARS names the model but gives no quantization guidance; see [Models and quantization](#models-and-quantization-two-models-both-at-q8) — Q8_0 (near-lossless) over the generic Q4_K_M default, since 128GB unified memory removes any capacity pressure to accept the quality hit | [Natural language processing](https://chasnelson1990.github.io/are-we-lcars-yet/open-source.html#row-nlp) |
| Model (coding agent) | — | **Qwen3-Coder-Next**, UD-Q8/Q8_0 | Planned | Named trade-off, see [Models and quantization](#models-and-quantization-two-models-both-at-q8): separate MoE model (80B total/3B active) instead of sharing Qwen3.6-27B, purpose-built for coding agents; adds operational complexity (two models) in exchange for a likely speed/quality edge on OpenHands specifically | — |
| Persistent agent memory | Letta | Letta | Planned | — | [Holographic crew](https://chasnelson1990.github.io/are-we-lcars-yet/open-source.html#row-holographic-crew) |
| Primary interface (chat client) | oterm / Open WebUI | **oterm + Open WebUI** | Planned | Named trade-off, see [Primary interface](#primary-interface-oterm--open-webui): oterm stays client-side (laptop, terminal) but has no phone story; Open WebUI added specifically to cover the handheld device, same Caddy+Tailscale reachability pattern as OpenHands, auth enabled | [Primary interface](https://chasnelson1990.github.io/are-we-lcars-yet/open-source.html#row-primary-interface) |
| Human-in-the-loop notifications | — | **Home Assistant actionable push notifications** | Planned | Named decision, see [Notifications](#notifications-unified-via-home-assistant-across-aegis-crewai-and-openhands): unifies AEGIS approvals, CrewAI's webhook-based HITL, and (goal) OpenHands async completions through one channel, since CrewAI has no viable self-hosted dashboard of its own (Enterprise-only, community alternatives dead) | — |
| CrewAI task creation UX | — | **Voice (HA Assist) + chat (Open WebUI Tools)** | Planned | Named decision, see [Creating CrewAI tasks](#creating-crewai-tasks-voice-and-chat-gating-only-what-runs): both call CrewAI's existing API-wrapper activation route; creation itself isn't AEGIS-gated, only what a task does once it's running | — |
| Agent framework (small daily tasks) | CrewAI | **CrewAI** | Planned | **Decided 2026-07-23**: compared in depth against LangGraph/AG2/OpenAI Agents SDK — CrewAI's Flows (`@persist` + `@human_feedback`) natively cover long-waiting scheduled tasks and an approval queue, and its guardrail gap is closed by AEGIS's native `BeforeToolCallHook` integration (see [AI safety/guardrails](#ai-safetyguardrails-aegis-garak-and-pyrit)), rather than needing a framework with built-in tool guardrails. **Activation: all three routes, not one exclusive mechanism** — an API wrapper (for on-demand triggers from other services, e.g. HA), scheduled/cron (via Flows' `@persist`, for recurring daily tasks), and manual CLI invocation (for ad hoc use) all fire the same underlying crew. Not a packaged app — needs a custom Dockerfile. Distinct from the coding agent row below | [Autonomous decision-making](https://chasnelson1990.github.io/are-we-lcars-yet/open-source.html#row-autonomous-decision-making) |
| Coding agent (replaces Claude Code usage) | — | **OpenHands** | Planned | Named trade-off, see [Coding agent](#coding-agent-openhands): sandboxing + self-hosted Tailscale-based remote access beat Goose (no sandbox web UI since v1.25.0, mobile via Cloudflare) and Aider (no sandboxing at all); hybrid ~99% local (Qwen3.6-27B) / 1% frontier-via-API-key | — |
| AI safety: runtime tool-call policy | NeMo Guardrails | **AEGIS** | Planned | Named trade-off, see [AI safety/guardrails](#ai-safetyguardrails-aegis-garak-and-pyrit): native CrewAI hook + built-in data-exfiltration detection map directly onto this household's rules; accepted risk that AEGIS is early-stage/single-maintainer, same shape of risk already accepted for Proton Pass CLI | [Autonomous decision-making](https://chasnelson1990.github.io/are-we-lcars-yet/open-source.html#row-autonomous-decision-making) |
| AI safety: offline red-teaming | garak + PyRIT | garak + PyRIT | Planned | — | [Autonomous decision-making](https://chasnelson1990.github.io/are-we-lcars-yet/open-source.html#row-autonomous-decision-making) |
| Container orchestration | Docker Compose (or Proxmox VE if virtualizing) | Docker Compose, hand-written on bare metal | Planned | No hypervisor, no appliance app-catalog: plain `docker compose up` per service, since OPNsense living on the router removes the reason to virtualize and TrueNAS is no longer in the picture | [Orchestration & deployment](https://chasnelson1990.github.io/are-we-lcars-yet/open-source.html#row-orchestration) |
| Reverse proxy / TLS | Caddy | Caddy | Planned | — | [Reverse proxy & TLS](https://chasnelson1990.github.io/are-we-lcars-yet/open-source.html#row-reverse-proxy) |
| DNS / network filtering | Pi-hole | Pi-hole | Planned | Needs host-network or macvlan config to bind port 53 with a stable LAN-reachable IP | [DNS & network-level filtering](https://chasnelson1990.github.io/are-we-lcars-yet/open-source.html#row-dns) |
| Password manager | Vaultwarden | **Proton Pass** | Planned | Already-paid Proton Unlimited subscription covers this; not adopting a self-hosted Bitwarden server | [Authorization method](https://chasnelson1990.github.io/are-we-lcars-yet/open-source.html#row-authorization-method) |
| Client VPN (privacy/exit) | — | **Proton VPN** | Planned | Same Proton Unlimited subscription; replaces `mullvad-vpn-bin` in the desktop config | — |
| Remote mesh access to homelab | Headscale | **Tailscale** | Planned | Named trade-off, see [`motivation.md`](../motivation.md#worked-example-tailscale-over-headscale): trades coordination-plane data-ownership for lower maintenance; complements Proton VPN, doesn't replace it | [Secure device networking](https://chasnelson1990.github.io/are-we-lcars-yet/open-source.html#row-secure-networking) |
| Metrics/observability | Netdata | Netdata | Planned | — | [Observability](https://chasnelson1990.github.io/are-we-lcars-yet/open-source.html#row-observability) |
| Uptime monitoring | Uptime Kuma | Uptime Kuma | Planned | — | [Uptime](https://chasnelson1990.github.io/are-we-lcars-yet/open-source.html#row-uptime) |
| UPS signalling | NUT | NUT, installed directly on the host | Planned | Not a container — no TrueNAS host feature to lean on anymore, so this is a native `nut` package install on bare Linux; hardware is **APC Smart-UPS SMT750I** over USB, see [UPS hardware](#ups-hardware-apc-smart-ups-smt750i) | [Power & UPS](https://chasnelson1990.github.io/are-we-lcars-yet/open-source.html#row-power-ups) |
| Voice control | Home Assistant Assist | Home Assistant Assist | Planned | — | [Primary interface](https://chasnelson1990.github.io/are-we-lcars-yet/open-source.html#row-primary-interface) |
| Speech-to-text (for Assist) | faster-whisper | **whisper.cpp**, via Wyoming, Vulkan backend, centralized on the compute core | Planned | Named trade-off, see [Voice pipeline](#voice-pipeline-whispercpp-vulkan--piper-centralized-on-the-compute-core): faster-whisper and ONNX Runtime-based alternatives (sherpa-onnx, Vosk) have no Vulkan path on AMD; whisper.cpp shares Ollama's Vulkan/Mesa/RADV backend | [Primary interface](https://chasnelson1990.github.io/are-we-lcars-yet/open-source.html#row-primary-interface) |
| Text-to-speech (for Assist) | Piper | Piper, via `piper1-gpl` (GPL-3.0), centralized on the compute core | Planned | Sourcing note, not a pick change: original `rhasspy/piper` (MIT) archived Oct 2025; install from the actively-maintained `piper1-gpl` fork. Kokoro considered and deferred (more natural voice, less mature Wyoming integration) — swappable later without touching the rest of the pipeline | [Primary interface](https://chasnelson1990.github.io/are-we-lcars-yet/open-source.html#row-primary-interface) |
| Heating control | — | Hive (official HA integration) | Planned | Cloud-dependent (Hive's own architecture), no local path available — see [Smart-home integrations](#smart-home-integrations-cloud-apis-only-no-local-radio-protocol-yet) | — |
| Robot vacuum | — | Samsung SmartThings integration | Planned | Mostly read-only (sensors only, unreliable control); free SmartThings API access ends Oct 2026, then needs a paid Samsung Personal Plan — accepted as a named trade-off, not fixed by this repo | — |
| Alarm system | — | SimpliSafe integration | Planned | No official API — reverse-engineered `simplipy` library, history of breaking on SimpliSafe-side auth changes — accepted, no vendor-supported alternative exists | — |
| Off-site backup | restic | **Borg, to Exoscale (Swiss S3)** | Planned | Named trade-off, see [Off-site backup](#off-site-backup-borg--exoscale): Borg over restic for language (Python) + ecosystem consistency with the laptop; Exoscale over Proton Drive/B2/rsync.net/Storj/Sia for jurisdiction outside the Fourteen Eyes, at a small cost premium over B2 | [Processing redundancy](https://chasnelson1990.github.io/are-we-lcars-yet/open-source.html#row-processing-redundancy) |
| Secrets management | — | **Proton Pass CLI** (PATs, host-level) | Planned | Named trade-off, see [Secrets management](#secrets-management-proton-pass-cli): reuses the existing Proton Unlimited subscription over introducing sops+age; accepted risk that pass-cli is still in beta | — |

## Decided: Caddy domain and DNS host

**Own domain (`chasnelson.co.uk`), migrating DNS hosting from 123-reg to deSEC** — chosen over
123-reg + acme-dns delegation specifically to get DNSSEC across the whole domain (mail and
website included), not just ACME automation for the homelab's wildcard cert. deSEC picked over
Cloudflare for alignment with `motivation.md` (non-profit, not a large commercial infrastructure
concentration), accepting deSEC's smaller institutional backing as the named trade-off. A
wildcard cert for `*.lab.chasnelson.co.uk` (not per-service certs) avoids leaking individual
service hostnames via Certificate Transparency logs; DNS records for that label point at the
compute core's Tailscale IP, so hostnames resolve everywhere but are only reachable from the
tailnet. **Migration is a live-infrastructure change requiring manual execution — full runbook
at [`docs/dns-migration-desec.md`](../docs/dns-migration-desec.md)**, since live Proton Mail and
the website are on this DNS today and can't be broken during cutover.

### Caddy hostname mapping

Every persistent, browser/API-facing service gets a `*.lab.chasnelson.co.uk` hostname behind
Caddy; purely internal or non-HTTP tools don't.

| Service | Hostname |
| --- | --- |
| Home Assistant | `home.lab.chasnelson.co.uk` |
| Pi-hole | `pihole.lab.chasnelson.co.uk` |
| Netdata | `netdata.lab.chasnelson.co.uk` |
| Uptime Kuma | `status.lab.chasnelson.co.uk` |
| OpenHands | `code.lab.chasnelson.co.uk` |
| AEGIS | `aegis.lab.chasnelson.co.uk` |
| Letta | `letta.lab.chasnelson.co.uk` |
| Ollama | `ollama.lab.chasnelson.co.uk` — wanted for convenience (human-readable in oterm's config, CLI use) even though most callers are other services, not a browser |
| CrewAI | `crew.lab.chasnelson.co.uk` — needs both API and CLI access, per the household's stated requirement, so it gets a stable hostname rather than staying bare-IP |
| Open WebUI | `chat.lab.chasnelson.co.uk` — the browser-facing primary interface for the handheld device (and anywhere else a browser's easier than oterm), see [Primary interface](#primary-interface-oterm--open-webui) |

**No hostname — internal-only or not applicable:**
- **whisper.cpp / Piper** — Wyoming protocol is TCP, not HTTP, and both are only ever called by
  Home Assistant's own Assist pipeline internally.
- **garak / PyRIT** — periodic red-teaming tools, run occasionally, not persistent services.
- **Proton Pass CLI** — a host-level CLI tool, not a service.
- **NUT** — CLI/HA-integration only, no web UI planned.
- **oterm** — runs on the laptop client itself, not hosted on the compute core at all.

## Open decisions

Everything above is provisional until the compute core is actually purchased and its OS
installed — treat "Planned" rows as intent, not commitment.

## Compute core: outstanding implementation items

Found 2026-07-23 by reviewing every "Planned" row above for what's genuinely decided vs. just a
category pick. Router hardware is tracked separately in [`router/README.md`](../router/README.md).

- [x] **Speech-to-text / text-to-speech for Home Assistant Assist** — Decided 2026-07-23:
      **whisper.cpp** (Vulkan) for STT, **Piper** (`piper1-gpl` fork) for TTS, both centralized
      on the compute core (Model A: terminal devices are thin clients over Wyoming) — see
      [Voice pipeline](#voice-pipeline-whispercpp-vulkan--piper-centralized-on-the-compute-core).
- [x] **Voice satellite hardware** — Decided 2026-07-23: **Home Assistant Voice Preview
      Edition**, over a DIY ESP32-S3-BOX-3/M5Stack/ReSpeaker build — see
      [Voice satellite hardware](#voice-satellite-hardware-home-assistant-voice-preview-edition).
      Quantity/room placement still open (household-layout question, not blocking).
- [x] **Smart-home device connectivity protocol** — Decided 2026-07-23: all three current
      devices (Hive, Samsung SmartThings/Jet Bot, SimpliSafe) integrate via cloud APIs, not a
      local radio protocol — so no Zigbee/Z-Wave/Thread coordinator is needed yet. Also settles
      HA's host: no Home Assistant Green, runs as a container on the compute core — see
      [Smart-home integrations](#smart-home-integrations-cloud-apis-only-no-local-radio-protocol-yet).
      Revisit the protocol question if/when a local-radio device is added.
- [x] **AI safety/guardrails layer** — Decided 2026-07-23: **AEGIS** for runtime tool-call policy
      enforcement (over LCARS's named NeMo Guardrails — better fit for precise rules like "never
      git push without approval," accepted early-stage-maturity risk); **garak + PyRIT** for
      offline red-teaming, as LCARS names — see
      [AI safety/guardrails](#ai-safetyguardrails-aegis-garak-and-pyrit).
- [x] **Secrets management approach** — Decided 2026-07-23: **Proton Pass CLI**, PAT-authenticated,
      running host-level on the compute core to populate the gitignored `.env` files before
      `docker compose up` — see [Secrets management](#secrets-management-proton-pass-cli).
      Accepted risk: the CLI is still in beta.
- [x] **UPS hardware** — Decided 2026-07-23: **APC Smart-UPS SMT750I**, over cheaper Back-UPS
      tiers (repairability — real board-level spare parts exist for Smart-UPS, unlike the
      disclosed "Repair: No" on Back-UPS Pro) and over CyberPower (shutdown-timing reliability).
      Victron MultiPlus considered and named as the more-repairable-but-more-effort alternative,
      not adopted — see [UPS hardware](#ups-hardware-apc-smart-ups-smt750i).
- [x] **CrewAI's actual container, and finalizing the "Agent framework" pick** — split into two
      while scoping this, both now decided 2026-07-23: (1) a genuinely new item, **the coding
      agent**, is **OpenHands**, replacing Claude Code usage, hybrid local/frontier — see
      [Coding agent](#coding-agent-openhands). (2) the original "Agent framework" row (small
      daily tasks) is **CrewAI**, confirmed against LangGraph/AG2/OpenAI Agents SDK — see that
      row in the software stack table. Activation isn't a single mechanism: API wrapper, cron
      schedule, and manual CLI invocation all trigger the same crew, not mutually exclusive
      choices. Neither container has actually been built yet — that's implementation work, not a
      decision, and isn't tracked as a separate checklist item.
- [x] **Model quantization** — Decided 2026-07-23, expanded into two models once the daily-task
      (CrewAI) and coding-agent (OpenHands) roles were split: **Qwen3.6-27B at Q8_0** for CrewAI,
      **Qwen3-Coder-Next (MoE, 80B/3B active) at UD-Q8/Q8_0** for OpenHands — see
      [Models and quantization](#models-and-quantization-two-models-both-at-q8).
- [x] **Caddy hostname mapping** — Decided 2026-07-23: nine services get a hostname (Home
      Assistant, Pi-hole, Netdata, Uptime Kuma, OpenHands, AEGIS, Letta, Ollama, CrewAI); Wyoming
      services, garak/PyRIT, Proton Pass CLI, NUT, and oterm don't — see
      [Caddy hostname mapping](#caddy-hostname-mapping).

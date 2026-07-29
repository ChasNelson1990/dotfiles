# DNS migration: 123-reg → deSEC

Runbook for moving `chasnelson.co.uk`'s authoritative DNS from 123-reg to
[deSEC](https://desec.io/), to get DNSSEC and native ACME (DNS-01) automation for the homelab's
wildcard certificate. See [`core/README.md`](../core/README.md) for the wider context this
decision sits inside.

## Context

This domain currently carries **live mail (Proton Mail, `@chasnelson.co.uk`) and the website** —
both must keep working through the migration. That rules out a rushed cutover: every MX, SPF,
DKIM, and DMARC record has to be replicated exactly before the switch, and DNS's TTL-based
caching means a mistake doesn't always show up immediately.

Confirmed before starting this plan: Caddy has a dedicated, non-deprecated
[`caddy-dns/desec`](https://github.com/caddy-dns/desec) module — no reliance on the generic
`lego-deprecated` shim.

**Do not run any of the cutover steps unattended or without first completing the preparation and
verification steps in order.**

## Phase 1 — Preparation (no risk, no live changes)

1. **Get the authoritative record values from Proton itself**, not just what currently resolves
   — open Proton Mail's admin panel → domain settings for `chasnelson.co.uk` and copy the exact
   required MX, SPF (TXT), DKIM (usually 3 CNAME records), and DMARC (TXT at `_dmarc`) values.
   Don't rely solely on `dig`/`nslookup` output in case anything already drifted from what Proton
   actually expects.
2. **Document every other existing record** at 123-reg: the website's A/AAAA/CNAME, any CAA
   records, any other verification TXT records (Google Search Console, etc.).
3. **Lower every record's TTL** at 123-reg to something short (e.g. 300s) at least 24–48 hours
   before the actual cutover, so stale caches expire quickly once the change happens. NS-level
   propagation at the registry is a separate, slower mechanism this doesn't fully control — see
   Phase 3.

## Phase 2 — Build the new zone in parallel (still no risk — not authoritative yet)

4. Create a deSEC account, add `chasnelson.co.uk` as a zone.
5. Re-enter **every** record from Phase 1 into deSEC — this is the step that most needs care.
   Cross-check against Proton's admin panel values again after entering them.
6. **Verify before cutover**, by querying deSEC's own nameservers directly (they're already
   answering, just not authoritative yet):
   ```
   dig @<a-desec-nameserver> MX chasnelson.co.uk
   dig @<a-desec-nameserver> TXT _dmarc.chasnelson.co.uk
   ```
   Confirm every record matches Proton's expected values before moving on.

## Phase 3 — Cutover

7. At 123-reg (the registrar), change the domain's nameservers to deSEC's.
8. **Wait and monitor** — NS delegation changes propagate through the parent (`.co.uk`) registry
   and can take up to 24–48 hours regardless of the lowered TTLs from Phase 1, since that's a
   different caching layer than record TTLs.
9. Verify continuously during this window:
   - Send and receive a real test email through the `@chasnelson.co.uk` address.
   - Check the website still resolves and loads.
   - Run the domain through [mxtoolbox.com](https://mxtoolbox.com) to confirm MX/SPF/DKIM/DMARC
     all still pass.
   - Keep the 123-reg records documented in Phase 1 on hand in case a rollback (reverting
     nameservers) is needed.

## Phase 4 — DNSSEC

10. Once the cutover is confirmed stable, enable DNSSEC signing on the deSEC zone (deSEC
    automates most of this).
11. deSEC provides a **DS record** — this must be entered at 123-reg's domain management panel
    (the registrar, not deSEC) to publish it in the `.co.uk` parent zone. DNSSEC will not actually
    validate until this step is done; pointing nameservers at deSEC alone isn't sufficient.
12. Verify with the [Verisign DNSSEC Debugger](https://dnssec-debugger.verisignlabs.com/) or
    [dnsviz.net](https://dnsviz.net/) — confirm a full, unbroken chain of trust.

## Phase 5 — Wire up Caddy

13. Configure Caddy's `desec` DNS provider module for the ACME DNS-01 challenge, targeting a
    wildcard cert for the homelab's internal label (e.g. `*.lab.chasnelson.co.uk`) — see
    `core/README.md` for the reasoning (wildcard specifically to avoid leaking individual
    service hostnames via Certificate Transparency logs).
14. The deSEC API token is a real secret — goes in a git-ignored `.env`, never the tracked
    `.env.example` template, per the public-repo convention already established in
    `core/README.md`.
15. Point the relevant DNS records at the compute core's **Tailscale IP**, not a public one, so
    the wildcard's hostnames resolve the same everywhere but are only actually reachable from
    devices on the tailnet.

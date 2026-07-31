# SSD migration — Phase 05: Verification

Part of the Framework laptop SSD cleanup/backup/encryption/restore runbook. See also:
[01 — Cleanup](ssd-migration-01-cleanup.md) ·
[02 — Backup](ssd-migration-02-backup.md) ·
[03 — Partition & encrypt](ssd-migration-03-partition-encrypt.md) ·
[04 — Restore & boot](ssd-migration-04-restore-and-boot.md)

## Context

Run through this checklist after rebooting from
[Phase 04](ssd-migration-04-restore-and-boot.md), before trusting the new disk
for daily use or deleting the backup archive.

## Checklist

- Machine boots to login without the USB — either silently auto-unlocking via
  TPM2, or falling back to a passphrase prompt.
- `lsblk -f` and `swapon --show` confirm the LUKS/LVM/swap layout is live, with
  a 64G swap LV.
- `systemctl status k3s` — start it with `sudo systemctl start k3s` if it
  hasn't come up on its own, then spot-check the previously-seen
  namespaces/PVCs (`zarr-staging`, `ckan-*`, `solr`) are present and healthy
  before resuming real use of `k3s`.
- `systemctl status power-profiles-daemon upower` — both should be active
  without intervention (their enablement state is a regular systemd symlink
  under `/etc`, carried over by the Phase 02 tar backup like everything else).
- `tailscale status` — should already show this device connected to the
  tailnet without re-running `sudo tailscale up`. `tailscaled`'s node state
  lives under `/var/lib/tailscale`, which the Phase 02 backup doesn't exclude,
  so the login should survive the migration intact.
- Confirm the Proton Pass PAT file itself, not just that `pass-cli` happens to
  work in your current shell — it's loaded by systemd's `EnvironmentFile=`
  directive in `borg_cjn-bak.service`, not read automatically by `pass-cli`,
  so a check that doesn't source it can pass even if the file is missing or
  unreadable, and running it inside `bash -ceu` (rather than as loose,
  pasted-in lines) makes a failed `test` actually stop the check instead of
  silently falling through to `pass-cli run` — and keeps the sourced
  variables out of your current shell:
  ```
  bash -ceu '
    unset PROTON_PASS_PERSONAL_ACCESS_TOKEN
    test -r ~/.config/proton-pass-cli.env
    set -a; . ~/.config/proton-pass-cli.env; set +a
    : "${PROTON_PASS_PERSONAL_ACCESS_TOKEN:?not set by the env file}"
    pass-cli run -- true
  ' && echo OK
  ```
  The Borg-to-Exoscale mirror (see [core/README.md](../core/README.md#off-site-backup-borg--exoscale))
  depends on this file silently; better to catch a permissions/ownership
  problem here than at the next scheduled backup run.
- Test hibernation deliberately, while at the machine and on AC power (don't
  test this on battery):
  ```
  sudo systemctl hibernate
  ```
  Power back on and confirm the session resumes rather than booting fresh.
- `cat /sys/power/resume` should reflect the swap LV's major:minor device
  numbers after boot.
- Keep the backup archive on the external drive for a while after all of the
  above passes, before deleting it.

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
- `pass-cli run -- true` (or similar) — confirms the Proton Pass PAT file at
  `~/.config/proton-pass-cli.env` survived with usable permissions. The
  Borg-to-Exoscale mirror (see [core/README.md](../core/README.md#off-site-backup-borg--exoscale))
  depends on it silently; better to catch a permissions/ownership problem here
  than at the next scheduled backup run.
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

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
- Test hibernation deliberately, while at the machine and on AC power (don't
  test this on battery):
  ```
  systemctl hibernate
  ```
  Power back on and confirm the session resumes rather than booting fresh.
- `cat /sys/power/resume` should reflect the swap LV's major:minor device
  numbers after boot.
- Keep the backup archive on the external drive for a while after all of the
  above passes, before deleting it.

# SSD migration — Phase 02: Back up the entire OS to the external drive

Part of the Framework laptop SSD cleanup/backup/encryption/restore runbook. See also:
[01 — Cleanup](ssd-migration-01-cleanup.md) ·
[03 — Partition & encrypt](ssd-migration-03-partition-encrypt.md) ·
[04 — Restore & boot](ssd-migration-04-restore-and-boot.md) ·
[05 — Verification](ssd-migration-05-verification.md)

## Context

The only external drive available is `/dev/sda1`, 931.5G **NTFS**, mounted at
`/run/media/chas/ravenwood`, already holding other data (897G free at last check).
NTFS cannot hold a raw Linux file tree (no POSIX permissions/xattrs/symlinks), so
the backup must be a single archive file — this also means the drive's existing
data is left untouched.

**Stop stateful services first** for a consistent snapshot (k3s owns embedded
datastore state):
```
sudo systemctl stop k3s
```

## Steps

The ArchWiki's tar-backup article is written for backing up an *offline* install
from a rescue chroot, but the core backup command applies directly to a live,
currently-booted system too — just run it directly, no chroot needed, since we're
already booted into the real install:

```
sudo tar --acls --xattrs -cpvaf \
  /run/media/chas/ravenwood/framework-backup-$(date +%F).tar.zst \
  --exclude=/proc --exclude=/sys --exclude=/dev --exclude=/run \
  --exclude=/tmp --exclude=/mnt --exclude=/media --exclude=/lost+found \
  --exclude=/run/media/chas/ravenwood \
  --exclude=/var/cache/pacman/pkg \
  /
```

(`-a` in `-cpvaf` auto-selects zstd compression from the `.tar.zst` extension;
`-p` plus `--acls --xattrs` is what preserves permissions/ACLs/xattrs — the wiki
explicitly warns that without both, many programs stop working after restore.)

Reference: [ArchWiki — Full system backup with tar](https://wiki.archlinux.org/title/Full_system_backup_with_tar)

## Verify before proceeding

**This is the point of no return for the internal disk.** Do not move on to
[Phase 03](ssd-migration-03-partition-encrypt.md) until this passes. Use the
exact filename produced above rather than a glob — if more than one backup
ever ends up on the drive, a glob expands to multiple paths and `tar -tf`
will misinterpret the extras as member patterns instead of archives to list:

```
tar --zstd -tf /run/media/chas/ravenwood/framework-backup-YYYY-MM-DD.tar.zst | tail -20
df -h /run/media/chas/ravenwood
```

Leave k3s stopped on this (old) install for the rest of the migration — the
disk is about to be wiped in [Phase 03](ssd-migration-03-partition-encrypt.md)
regardless. On the new disk, k3s will auto-start via systemd after reboot;
don't rely on it for real work until its health is confirmed in
[Phase 05 — Verification](ssd-migration-05-verification.md).

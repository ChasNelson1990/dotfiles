# SSD migration — Phase 01: Clean up the current drive

Part of the Framework laptop SSD cleanup/backup/encryption/restore runbook. See also:
[02 — Backup](ssd-migration-02-backup.md) ·
[03 — Partition & encrypt](ssd-migration-03-partition-encrypt.md) ·
[04 — Restore & boot](ssd-migration-04-restore-and-boot.md) ·
[05 — Verification](ssd-migration-05-verification.md)

## Context

Before backing up ~750G of data, reclaim the obvious junk first: an unemptied
Trash (~128G), a bloated pacman package cache (~112G), and
orphaned packages (82 at last count). This shrinks and speeds up the backup in
[Phase 02](ssd-migration-02-backup.md) — none of it is necessary, but it's free.

Run these on the live system now. All of it is reversible or already-discarded data.

## Steps

1. **Empty trash** (~128G) — clear the contents of the `files`/`info`
   subdirectories rather than the `Trash/*` glob, which would delete those
   subdirectories themselves (some tools, including this repo's ranger config,
   expect `Trash/files/` to exist as a directory). Using `find -delete`
   instead of a glob avoids a shell error if either directory happens to
   already be empty (an unmatched glob aborts the command under zsh's
   default `nomatch` option):
   ```
   mkdir -p ~/.local/share/Trash/files ~/.local/share/Trash/info
   find ~/.local/share/Trash/files ~/.local/share/Trash/info -mindepth 1 -delete
   ```

2. **Prune the pacman package cache**, keeping only the most recent version of each package:
   ```
   sudo paccache -rk1
   ```
   To also drop cached versions of packages no longer installed at all:
   ```
   sudo paccache -ruk0
   ```
   Reference: [ArchWiki — Pacman § Cleaning the package cache](https://wiki.archlinux.org/title/Pacman#Cleaning_the_package_cache)

3. **Remove orphaned packages** — review the list first, then remove.
   `xargs -r` makes this a no-op instead of erroring when there are no
   orphans (a common, benign case):
   ```
   pacman -Qdtq
   pacman -Qdtq | xargs -r sudo pacman -Rns --
   ```
   Reference: [ArchWiki — Pacman/Tips and tricks § Removing unused packages (orphans)](https://wiki.archlinux.org/title/Pacman/Tips_and_tricks#Removing_unused_packages_(orphans))

4. Recheck headroom:
   ```
   df -h /
   ```

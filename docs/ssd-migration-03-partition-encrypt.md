# SSD migration — Phase 03: Create the Arch installer USB and repartition/encrypt the SSD

Part of the Framework laptop SSD cleanup/backup/encryption/restore runbook. See also:
[01 — Cleanup](ssd-migration-01-cleanup.md) ·
[02 — Backup](ssd-migration-02-backup.md) ·
[04 — Restore & boot](ssd-migration-04-restore-and-boot.md) ·
[05 — Verification](ssd-migration-05-verification.md)

## Context

Current internal disk layout (unencrypted): `/dev/nvme0n1`, 931.5G, GPT — `p1` 1G
vfat `/boot` (ESP), `p2` 8G swap, `p3` 922.5G ext4 `/`.

This phase wipes that layout and replaces it with LUKS2 + LVM ("LVM on LUKS"),
giving a real 64G swap logical volume — large enough to actually hibernate
60GB+ of RAM, unlike the previous 8G swap partition — with a single
passphrase/TPM2 unlock for both root and swap.

Do not start this phase until the backup in
[Phase 02](ssd-migration-02-backup.md) is verified complete.

## Steps

1. **Get a spare USB stick** (separate from the ravenwood backup drive) and write
   the Arch ISO to it:
   ```
   sudo dd bs=4M if=path/to/archlinux-version-x86_64.iso of=/dev/disk/by-id/usb-My_flash_drive conv=fsync oflag=direct status=progress
   ```
   Identify the correct `/dev/disk/by-id/...` device carefully before running
   this — it is destructive to whatever is currently on that stick.
   Reference: [ArchWiki — USB flash installation medium § In GNU/Linux](https://wiki.archlinux.org/title/USB_flash_installation_medium#In_GNU/Linux)

2. Boot the Framework laptop from that USB into the Arch live environment.

3. Confirm the target disk is still `/dev/nvme0n1`, wipe it, and create a fresh
   GPT with an ESP + one large partition for LUKS:
   ```
   sgdisk --zap-all /dev/nvme0n1
   parted /dev/nvme0n1 --script mklabel gpt
   parted /dev/nvme0n1 --script mkpart ESP fat32 1MiB 1025MiB
   parted /dev/nvme0n1 --script set 1 esp on
   parted /dev/nvme0n1 --script mkpart primary 1025MiB 100%
   ```
   General partitioning guidance: [ArchWiki — Installation guide § Partition the disks](https://wiki.archlinux.org/title/Installation_guide#Partition_the_disks)

4. **Encrypt the second partition with LUKS2, then put root + swap inside via LVM**
   ("LVM on LUKS" — the standard scheme for encrypted swap/hibernation with a
   single passphrase/TPM unlock):
   ```
   cryptsetup luksFormat --type luks2 /dev/nvme0n1p2
   cryptsetup open /dev/nvme0n1p2 cryptlvm

   pvcreate /dev/mapper/cryptlvm
   vgcreate vg0 /dev/mapper/cryptlvm
   lvcreate -L 64G -n swap vg0
   lvcreate -l 100%FREE -n root vg0

   mkfs.fat -F32 /dev/nvme0n1p1
   mkfs.ext4 /dev/vg0/root
   mkswap /dev/vg0/swap
   ```
   Reference: [ArchWiki — Dm-crypt/Encrypting an entire system § LVM on LUKS](https://wiki.archlinux.org/title/Dm-crypt/Encrypting_an_entire_system#LVM_on_LUKS)
   (covers `luksFormat`, `open`, `pvcreate`, `vgcreate`, `lvcreate`, and the
   boot-partition formatting shown above), plus
   [ArchWiki — LVM § Installation](https://wiki.archlinux.org/title/LVM#Installation)
   (confirms the `lvm2` package requirement, used again in
   [Phase 04](ssd-migration-04-restore-and-boot.md)'s initramfs hooks).

# SSD migration — Phase D: Restore the OS onto the new encrypted disk and reconfigure boot

Part of the Framework laptop SSD cleanup/backup/encryption/restore runbook. See also:
[01 — Cleanup](ssd-migration-01-cleanup.md) ·
[02 — Backup](ssd-migration-02-backup.md) ·
[03 — Partition & encrypt](ssd-migration-03-partition-encrypt.md) ·
[05 — Verification](ssd-migration-05-verification.md)

## Context

At this point the new disk has an unencrypted ESP (`/dev/nvme0n1p1`) and an
LUKS2+LVM container (`/dev/vg0/root`, `/dev/vg0/swap`) from
[Phase C](ssd-migration-03-partition-encrypt.md), and the tar backup from
[Phase B](ssd-migration-02-backup.md) is ready to extract. Bootloader is
systemd-boot; its entry lives at `/boot/loader/entries/arch.conf`.

## Steps

1. Mount everything and extract the backup:
   ```
   mount /dev/vg0/root /mnt
   mount --mkdir /dev/nvme0n1p1 /mnt/boot
   tar --acls --xattrs-include=* --zstd -xpf /path/to/framework-backup-*.tar.zst -C /mnt
   swapon /dev/vg0/swap
   ```
   Note the extraction flag is `--xattrs-include=*`, not just `--xattrs` — the
   wiki's restore example uses this exact form; without it, tar's default
   include pattern silently drops some xattrs on extraction.
   Reference: [ArchWiki — Full system backup with tar § Restoring](https://wiki.archlinux.org/title/Full_system_backup_with_tar#Restoring)

2. Generate fstab and enter the new system:
   ```
   genfstab -U /mnt >> /mnt/etc/fstab
   ```
   Check the resulting file, then:
   ```
   arch-chroot -S /mnt
   ```
   References:
   [ArchWiki — Installation guide § Fstab](https://wiki.archlinux.org/title/Installation_guide#Fstab),
   [ArchWiki — Installation guide § Chroot](https://wiki.archlinux.org/title/Installation_guide#Chroot)

3. **Inside the chroot**, add an `/etc/crypttab` entry for the LUKS container so
   it's known to the system beyond the boot-time unlock (find its UUID with
   `blkid /dev/nvme0n1p2` first) — optional for boot itself (the kernel
   parameter in step 5 handles early unlock) but keeps `cryptlvm` consistently
   named. Two fields (name + device) is sufficient to prompt for the passphrase
   at boot, matching the wiki's own LUKS example (`home  /dev/lvm/home`):
   ```
   echo "cryptlvm UUID=<luks-uuid-here>" >> /etc/crypttab
   ```
   Reference: [ArchWiki — Dm-crypt/System configuration § crypttab](https://wiki.archlinux.org/title/Dm-crypt/System_configuration#crypttab)
   (verified exact example syntax on the page: `name  device  password  options`,
   with a bare `home  /dev/lvm/home` line documented as "Mount /dev/lvm/home ...
   using LUKS, and prompt for the passphrase at boot time").

4. **Update `/etc/mkinitcpio.conf`** — confirm `lvm2` is installed, then set
   `HOOKS` to the systemd + LVM + encryption combination:
   ```
   HOOKS=(base systemd autodetect microcode modconf kms keyboard sd-vconsole block sd-encrypt lvm2 filesystems fsck)
   ```
   Then regenerate the initramfs for all presets:
   ```
   mkinitcpio -P
   ```
   References:
   [ArchWiki — Dm-crypt/System configuration § mkinitcpio](https://wiki.archlinux.org/title/Dm-crypt/System_configuration#mkinitcpio)
   (this exact `HOOKS` line, systemd-based variant, is given verbatim on this page),
   [ArchWiki — Mkinitcpio § Image creation and activation](https://wiki.archlinux.org/title/Mkinitcpio#Image_creation_and_activation)
   (for `mkinitcpio -P`).

5. **Update the boot loader entry** at `/boot/loader/entries/arch.conf` — set
   the kernel command line to unlock the LUKS container and boot from the LVM
   root, plus the hibernate resume target:
   ```
   title   Arch Linux
   linux   /vmlinuz-linux
   initrd  /initramfs-linux.img
   options rd.luks.name=<luks-uuid-here>=cryptlvm root=/dev/vg0/root rw resume=/dev/vg0/swap
   ```
   `<luks-uuid-here>` is the LUKS superblock UUID from `blkid /dev/nvme0n1p2`
   (same value as used in `/etc/crypttab` above).

   References:
   [ArchWiki — Dm-crypt/System configuration § Kernel parameters](https://wiki.archlinux.org/title/Dm-crypt/System_configuration#Kernel_parameters)
   (for `rd.luks.name=...=cryptlvm root=/dev/MyVolGroup/root` syntax),
   [ArchWiki — systemd-boot § Adding loaders](https://wiki.archlinux.org/title/Systemd-boot#Adding_loaders)
   (loader entry file format),
   [ArchWiki — Power management/Suspend and hibernate § Manually specify hibernate location](https://wiki.archlinux.org/title/Power_management/Suspend_and_hibernate#Manually_specify_hibernate_location)
   (confirms `resume=/dev/archVolumeGroup/archLogicalVolume` is the correct form
   when swap is an LVM logical volume, and that for a stacked/encrypted device
   the parameter must point at the *unlocked* mapped device, i.e. `/dev/vg0/swap`,
   not the raw partition).

   Note from the same hibernate page: on UEFI systems `systemd-sleep` can
   auto-select the swap target via a `HibernateLocation` EFI variable, making an
   explicit `resume=` unnecessary — but setting it explicitly, as above, is
   unambiguous and is what this runbook uses.

6. Reinstall the bootloader to the new ESP:
   ```
   bootctl install
   ```
   Reference: [ArchWiki — systemd-boot § Installing the UEFI boot manager](https://wiki.archlinux.org/title/Systemd-boot#Installing_the_UEFI_boot_manager)

7. **Enroll TPM2 for auto-unlock** in addition to the passphrase (this adds a
   second unlock method, it does not remove the passphrase — keep the
   passphrase as a fallback for when firmware/BIOS updates change TPM PCR
   measurements and auto-unlock stops working):
   ```
   systemd-cryptenroll --tpm2-device=list
   systemd-cryptenroll --tpm2-device=auto --tpm2-pcrs=7 /dev/nvme0n1p2
   ```
   Reference: [ArchWiki — systemd-cryptenroll § Trusted Platform Module](https://wiki.archlinux.org/title/Systemd-cryptenroll#Trusted_Platform_Module)
   (this exact `--tpm2-device=auto --tpm2-pcrs=7` command, and the note that
   PCR 7 is a common baseline measurement — adjust if you also want to bind to
   Secure Boot state or other PCRs, per the page's guidance).

8. Exit the chroot, unmount everything, and reboot without the USB stick:
   ```
   exit
   umount -R /mnt
   swapoff /dev/vg0/swap
   reboot
   ```

Continue to [Phase 05 — Verification](ssd-migration-05-verification.md).

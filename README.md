# dotfiles

A living repository including a list of installed software and containing global configuration files where appropriate.

## Operating System

This set-up is for a DELL XPS 13 9380 running Arch Linux.

## Configuration files

Configuration files exist for:

- Alacritty for terminal emulator (https://sw.kovidgoyal.net/alacritty/)
- betterlockscreen for... well... y'know (https://github.com/betterlockscreen/betterlockscreen)
- BorgBackup (https://www.borgbackup.org/)
- clamAV for antivirus (https://www.clamav.net/)
- VSCode (https://code.visualstudio.com/)
  - N.B. I currently use the proprietary build for access to the Remote-SSH features
- dunst for notifications (https://dunst-project.org)
- i3 for window management (https://i3wm.org/)
- i3bar with i3status (https://i3wm.org/)
- [Oh My] ZSH (https://ohmyz.sh/)
- Ranger for file browser (https://ranger.github.io/)
- Redshift (http://jonls.dk/redshift/)
- rofi for launcher (https://github.com/davatorium/rofi)
- starship as prompt (https://starship.rs/)

## Installed Packages

`packages.txt` includes a list of key OS packages installed. FIXME OUTDATED

## Custom Packages

Also includes custom PKGBUILD files for:

- otf-sansguilt (https://fontlibrary.org/en/font/sans-guilt)

## Manual Steps

- Note that current BorgBackup script (`/local/bin/borg_cjn-bak.sh`) uses an empty passphrase and a local file key, which is automatically created in `config/borg/keys` for new systems but must be manually copied across to access an existing repository, i.e. with a clean install.

## TODO

-[ ] Create a script to auto update `packages.txt.` -[ ] Create a script to auto-install from `packages.txt`

## Notes to self

- Remember that symlinks should be relative to ~

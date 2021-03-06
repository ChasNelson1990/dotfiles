# dotfiles

A living repository including a list of installed software and containing global configuration files where appropriate.

## Operating System

This set-up is for a DELL XPS 13 9380 running Arch Linux.

## Configuration files

Configuration files exist for:

* Sway (https://swaywm.org)
* Swaylock (https://github.com/swaywm/swaylock)
* Waybar (https://github.com/Alexays/Waybar)
* Ranger (https://ranger.github.io/)
* Kitty (https://sw.kovidgoyal.net/kitty/)
* Redshift (http://jonls.dk/redshift/)
* Kanshi (https://wayland.emersion.fr/kanshi/)
* Albert (https://albertlauncher.github.io/)
* Artha (http://artha.sourceforge.net/wiki/index.php/Home)
* [Oh My] ZSH (https://ohmyz.sh/)
* BorgBackup (https://www.borgbackup.org/)
* Mako (https://wayland.emersion.fr/mako/)
* VSCode (https://code.visualstudio.com/)
  * N.B. I currently use the proprietary build for access to the Remote-SSH features

## Installed Packages

`packages.txt` includes a list of key OS packages installed

## Custom Packages

Also includes custom PKGBUILD files for:

* otf-sansguilt (https://fontlibrary.org/en/font/sans-guilt)

## Manual Steps

* Note that current BorgBackup script (`/local/bin/borg_cjn-bak.sh`) uses an empty passphrase and a local file key, which is automatically created in `config/borg/keys` for new systems but must be manually copied across to access an existing repository, i.e. with a clean install.

## TODO:

-[ ] Create a script to auto update `packages.txt.`
-[ ] Create a script to auto-install from `packages.txt`

## Notes to self

* Remember that symlinks should be relative to ~

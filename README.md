# dotfiles

A living repository including a list of installed software and containing global configuration files where appropriate.

## Operating System

This set-up is for a DELL XPS 13 9380 running Arch Linux.

## Configuration files

Configuration files exist for:
* Sway (https://swaywm.org)
* Waybar (https://github.com/Alexays/Waybar)
* Ranger (https://ranger.github.io/)
* Termite (https://github.com/thestinger/termite)
* Redshift (http://jonls.dk/redshift/)
* Kanshi (https://wayland.emersion.fr/kanshi/)
* Albert (https://albertlauncher.github.io/)
* Artha (http://artha.sourceforge.net/wiki/index.php/Home)
* [Oh My] ZSH (https://ohmyz.sh/)
* BorgBackup (https://www.borgbackup.org/)

## Installed Packages

`packages.txt` includes a list of key OS packages installed

## Manual Steps

* Note that current BorgBackup scripts (`/local/bin/borg_hdd.sh`, `/local/bin/borg_beag-shuil.sh`) each require a passphrase to be added and a file key to be put in `config/borg/keys` before running the install file. Remember to keep both of these changes dirty and not committed. If not set, it defaults to a blank passphrase (less secure anyway) but will fail due to the lack of file.

## TODO:

-[ ] Create a script to auto update `packages.txt.`
-[ ] Create a script to auto-install from `packages.txt`
-[ ] Create a script to auto 'install' configuration files, i.e. create appropriate symlinks

## Notes to self

* Remember that symlinks should be relative to ~

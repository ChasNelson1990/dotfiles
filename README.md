# dotfiles

A living repository including a list of installed software and containing global configuration files where appropriate.

## Operating System

This set-up is for a Framework 13 AMD Ryzen 7040 running Arch Linux.

## Configuration files

Configuration files exist for:

- [Alacritty](https://sw.kovidgoyal.net/alacritty/) for terminal emulator
- [betterlockscreen](https://github.com/betterlockscreen/betterlockscreen) for... well... y'know
- [BorgBackup](https://www.borgbackup.org/)
- [clamAV](https://www.clamav.net/) for antivirus
- [VSCode](https://code.visualstudio.com/)
- [i3](https://i3wm.org/) for window management
- i3bar with [i3status-rust](https://github.com/greshake/i3status-rust)
- [Oh My ZSH](https://ohmyz.sh/)
- [Ranger](https://ranger.github.io/) for file browser
- [Redshift](http://jonls.dk/redshift/)
- [rofi](https://github.com/davatorium/rofi) for launcher
- [starship](https://starship.rs/) as prompt
- [wired](https://github.com/Toqozz/wired-notify) for notifications

## Installed Packages

| **_Category_**     |                       |                          |                        |                  |                        |                |                   |             |                  |           |                  |             |               |
| ------------------ | --------------------- | ------------------------ | ---------------------- | ---------------- | ---------------------- | -------------- | ----------------- | ----------- | ---------------- | --------- | ---------------- | ----------- | ------------- |
| **3D**             | blender               | openscad                 |                        |                  |                        |                |                   |             |                  |           |                  |             |               |
| **Audio**          | audacity              | pipewire                 | pipewire-alsa          | pipewire-jack    | pipewire-pulse         | pipewire-v4l2  | pipewire-audio    | wireplumber |                  |           |                  |             |               |
| **Communications** | signal-desktop        | skypeforlinux-stable-bin | slack-desktop          | telegram-desktop |                        |                |                   |             |                  |           |                  |             |               |
| **DevOps**         | aws-cli-v2            | azure-cli                | dbeaver                | docker           | docker-buildx          | minikube       | postman-bin       |             |                  |           |                  |             |               |
| **Documents**      | hunspell-en_GB        | libreoffice-fresh-en-gb  | mailspring             | qpdf             | xournalpp              |                |                   |             |                  |           |                  |             |               |
| **Fonts**          | otf-monaspace-nerd    | otf-font-awesome-4       |                        |                  |                        |                |                   |             |                  |           |                  |             |               |
| **GUI**            | betterlockscreen      | i3-layouts               | i3-wm                  | i3blocks         | i3status-rust          | i3wsr          | redshift          | rofi        | rofi-vscode-mode | wired-git | xorg-xinit       | xorg-server | xorg-xsetroot |
| **Imaging**        | darktable             | feh                      | gimp                   | graphics-magick  | inkscape               |                |                   |             |                  |           |                  |             |               |
| **Internet**       | chromium              | firefox                  | firefox-i18n-en-gb     | google-chrome    |                        |                |                   |             |                  |           |                  |             |               |
| **Monitoring**     | btm                   | cpupower                 | hddtemp                | htop             | Iio-sensor-proxy       | lm_sensors     | powertop          | procs       | tlp              |           |                  |             |               |
| **Networking**     | bandwhich             | clamav                   | curlie                 | firewalld        | mullvad-vpn-bin        | networkmanager | python-fangfrisch |             |                  |           |                  |             |               |
| **Programming**    | nvm                   | pyenv                    | r                      | texlive          | visual-studio-code-bin |                |                   |             |                  |           |                  |             |               |
| **Shell**          | alacritty             | mcfly                    | oh-my-zsh-git          | starship         | tealdeer               | direnv         |                   |             |                  |           |                  |             |               |
| **Storage**        | duf                   | dust                     | exfat-utils            | mlocate          | ntfs-3g                | ranger         | zip               |             |                  |           |                  |             |               |
| **System**         | bat                   | brightnessctl            | exa                    | fd               | fwupd                  | ripgrep        | sd                | zoxide      |                  |           |                  |             |               |
| **Utilities**      | android-file-transfer | borg                     | flameshot              | fprintd          | gnome-keyring          | kalu           | less              | libfprint   | macchina         | paru      | transmission-gtk |             |               |
| **VCS**            | git                   | git-lfs                  | github-cli             |                  |                        |                |                   |             |                  |           |                  |             |               |
| **Video**          | obs-studio            | shotcut                  | v4l-utils              | vlc              |                        |                |                   |             |                  |           |                  |             |               |

## Custom Packages

Also includes custom PKGBUILD files for:

- otf-sansguilt (https://fontlibrary.org/en/font/sans-guilt)

## Manual Steps

- Note that current BorgBackup script (`/local/bin/borg_cjn-bak.sh`) uses an empty passphrase and a local file key, which is automatically created in `config/borg/keys` for new systems but must be manually copied across to access an existing repository, i.e. with a clean install.

## Notes to self

- Remember that symlinks should be relative to ~

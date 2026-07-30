# Terminal

Status: **Running**.

The Framework 13's own configuration — window manager, terminal, shell, and every desktop tool
listed below. See the [top-level README](../README.md) for how this fits alongside the other
devices, and [`motivation.md`](../motivation.md) for the philosophy behind the choices made here.

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
| **DevOps**         | dbeaver               | docker                   | docker-buildx          | docker-compose   | kubectl                | minikube       | postman-bin       |             |                  |           |                  |             |               |
| **Documents**      | hunspell-en_GB        | libreoffice-fresh-en-gb  | mailspring             | qpdf             | xournalpp              |                |                   |             |                  |           |                  |             |               |
| **Fonts**          | otf-monaspace-nerd    | otf-font-awesome-4       |                        |                  |                        |                |                   |             |                  |           |                  |             |               |
| **GUI**            | betterlockscreen      |                | i3-wm                  | i3blocks         | i3status-rust          | i3wsr          | redshift          | rofi        | rofi-vscode-mode | wired-git | xorg-xinit       | xorg-server | xorg-xsetroot |
| **Imaging**        | darktable             | feh                      | gimp                   | graphics-magick  | inkscape               |                |                   |             |                  |           |                  |             |               |
| **Internet**       | chromium              | firefox                  | firefox-i18n-en-gb     | google-chrome    |                        |                |                   |             |                  |           |                  |             |               |
| **Monitoring**     | btm                   | cpupower                 | hddtemp                | htop             | Iio-sensor-proxy       | lm_sensors     | powertop          | procs       | tlp              |           |                  |             |               |
| **Networking**     | bandwhich             | clamav                   | curlie                 | firewalld        | proton-vpn-cli         | networkmanager | python-fangfrisch | tailscale   |                  |           |                  |             |               |
| **Programming**    | nvm                   | pyenv                    | r                      | texlive          | uv                     | visual-studio-code-bin |           |             |                  |           |                  |             |               |
| **Shell**          | alacritty             | mcfly                    | oh-my-zsh-git          | starship         | tealdeer               | direnv         |                   |             |                  |           |                  |             |               |
| **Storage**        | duf                   | dust                     | exfat-utils            | mlocate          | ntfs-3g                | ranger         | zip               |             |                  |           |                  |             |               |
| **System**         | bat                   | brightnessctl            | eza                    | fd               | fwupd                  | ripgrep        | sd                | zoxide      |                  |           |                  |             |               |
| **Utilities**      | android-file-transfer | borg                     | flameshot              | fprintd          | gnome-keyring          | kalu           | less              | libfprint   | macchina         | paru      | transmission-gtk |             |               |
| **VCS**            | git                   | git-lfs                  | github-cli             |                  |                        |                |                   |             |                  |           |                  |             |               |
| **Video**          | obs-studio            | shotcut                  | v4l-utils              | vlc              |                        |                |                   |             |                  |           |                  |             |               |

## Custom Packages

Also includes custom PKGBUILD files for:

- otf-sansguilt (https://fontlibrary.org/en/font/sans-guilt)

## Manual Steps

- Note that current BorgBackup script (`local/bin/borg_cjn-bak.sh`) uses an empty passphrase and a local file key, which is automatically created in `config/borg/keys` for new systems but must be manually copied across to access an existing repository, i.e. with a clean install.
- Password manager: [Proton Pass](https://proton.me/pass), via its Firefox extension — not a standalone package, so `install.sh` doesn't cover it. Install from the exact listing at [addons.mozilla.org/firefox/addon/proton-pass](https://addons.mozilla.org/en-US/firefox/addon/proton-pass/) (not a generic Add-ons search, to avoid an impersonating lookalike) — confirm the publisher shown is **Proton** before installing — then sign in with the existing Proton Unlimited account.
- Tailscale: `install.sh` installs the package and enables `tailscaled.service`, but joining the tailnet needs an interactive browser login — run `sudo tailscale up` manually once, per [the homelab's remote-mesh decision](../core/README.md#software-stack) (this laptop is a client on the same tailnet as the compute core, reaching its `*.lab.chasnelson.co.uk` hostnames).

## Notes to self

- Remember that symlinks should be relative to ~

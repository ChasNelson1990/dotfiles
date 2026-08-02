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

| **_Category_**     |                       |                          |                        |                  |                        |                |                   |             |                  |           |                  |             |               |               |               |
| ------------------ | --------------------- | ------------------------ | ---------------------- | ---------------- | ---------------------- | -------------- | ----------------- | ----------- | ---------------- | --------- | ---------------- | ----------- | ------------- | ------------------- | ------------------- |
| **3D**             | openscad              |                          |                        |                  |                        |                |                   |             |                  |           |                  |             |               |               |               |
| **Audio**          | audacity              | pavucontrol              | pipewire               | pipewire-alsa    | pipewire-jack          | pipewire-pulse | pipewire-v4l2     | pipewire-audio | rtkit        | wireplumber |              |             |               |               |               |
| **Communications** | signal-desktop        | slack-desktop            | telegram-desktop      |                  |                        |                |                   |             |                  |           |                  |             |               |               |               |
| **DevOps**         | ctop                  | dbeaver                  | docker                 | docker-buildx    | docker-compose         | kubectl        | minikube          | postman-bin |                  |           |                  |             |               |               |               |
| **Documents**      | hunspell-en_gb        | libreoffice-fresh-en-gb  | mupdf                  | qpdf             | xournalpp              |                |                   |             |                  |           |                  |             |               |               |               |
| **Fonts**          | noto-fonts-emoji      | otf-monaspace-nerd       | otf-font-awesome-4     |                  |                        |                |                   |             |                  |           |                  |             |               |               |               |
| **GUI**            | autorandr             | betterlockscreen         | i3-wm                  | i3blocks         | i3status-rust          | i3wsr          | redshift          | rofi        | rofi-vscode-mode | wired     | xorg-xinit       | xorg-server | xorg-xsetroot | rofi-power-menu |               |
| **Imaging**        | argyllcms             | darktable                | feh                    | gimp             | graphicsmagick         | inkscape       |                   |             |                  |           |                  |             |               |               |               |
| **Internet**       | chromium              | firefox                  | firefox-developer-edition | firefox-i18n-en-gb | google-chrome     | torbrowser-launcher |               |             |                  |           |                  |             |               |               |               |
| **Monitoring**     | batsignal             | battop                   | bottom                  | cpupower         | hddtemp                | htop           | iotop             | lm_sensors  | power-profiles-daemon | powertop | procs        | upower      |               |               |               |
| **Networking**     | bandwhich               | bind                    | bluez-utils             | clamav                  | curlie                  | filezilla               | firewalld               | iftop                   | nethogs                 | ngrok                   | proton-pass-cli-bin     | proton-vpn-cli          | networkmanager          | python-fangfrisch       | tailscale               |
| **Programming**    | nvm                   | pyenv                    | r                      | texlive          | uv                     | visual-studio-code-bin |           |             |                  |           |                  |             |               |               |               |
| **Shell**          | alacritty             | direnv                   | mcfly                  | oh-my-zsh-git    | starship               | tealdeer       | vim               | zsh         |                  |           |                  |             |               |               |               |
| **Storage**        | dosfstools            | duf                      | dust                   | exfat-utils      | gdu                    | nfs-utils      | ntfs-3g           | plocate     | ranger           | rclone    | zip              |             |               |               |               |
| **System**         | bat                   | brightnessctl            | eza                    | fd               | fwupd                  | ripgrep        | sd                | sysfsutils  | usbutils         | zoxide    |                  |             |               |               |               |
| **Utilities**      | android-file-transfer | borg                     | flameshot              | fprintd          | gnome-keyring          | kalu           | less              | libfprint   | macchina         | paru      | transmission-gtk |             |               |               |               |
| **VCS**            | git                   | git-lfs                  | github-cli             |                  |                        |                |                   |             |                  |           |                  |             |               |               |               |
| **Video**          | obs-studio            | shotcut                  | v4l-utils              | vlc              |                        |                |                   |             |                  |           |                  |             |               |               |               |

## Custom Packages

Also includes custom PKGBUILD files for:

- otf-sansguilt (https://fontlibrary.org/en/font/sans-guilt)

## Manual Steps

- Note that current BorgBackup script (`local/bin/borg_cjn-bak.sh`) uses a local file key, which is automatically created in `config/borg/keys` for new systems but must be manually copied across to access an existing repository, i.e. with a clean install. The passphrase itself is no longer blank — it's pulled from Proton Pass at run time (see below), so the keyfile alone isn't enough to decrypt a backup on its own.
- Borg's off-site mirror to Exoscale (see [core/README.md](../core/README.md#off-site-backup-borg--exoscale)) needs three things set up once, none of them tracked in this repo:
  1. A `pass-cli`-authenticated Proton Pass PAT, scoped to a dedicated vault, saved as `PROTON_PASS_PERSONAL_ACCESS_TOKEN=...` in `~/.config/proton-pass-cli.env` (not git-tracked — lives outside this repo entirely).
  2. Matching Pass vault items for the three `pass://Homelab/...` references in `config/systemd/user/borg_cjn-bak.service` — a `laptop-borg-backup` item with a `password` field, and an `exoscale-sos` item with `access-key-id`/`secret-access-key` fields (rename the references in that file if different vault/item names are used).
  3. `BORG_OFFSITE_BUCKET` — replace the placeholder in `local/bin/borg_cjn-bak.sh` with the real Exoscale bucket name, or override it via an env var (not a secret, just not yet a real value in the tracked template).
- Password manager: [Proton Pass](https://proton.me/pass), via its Firefox extension — not a standalone package, so `install.sh` doesn't cover it. Install from the exact listing at [addons.mozilla.org/firefox/addon/proton-pass](https://addons.mozilla.org/en-US/firefox/addon/proton-pass/) (not a generic Add-ons search, to avoid an impersonating lookalike) — confirm the publisher shown is **Proton** before installing — then sign in with the existing Proton Unlimited account.
- Tailscale: `install.sh` installs the package and enables `tailscaled.service`, but joining the tailnet needs an interactive browser login — run `sudo tailscale up` manually once, per [the homelab's remote-mesh decision](../core/README.md#software-stack) (this laptop is a client on the same tailnet as the compute core, reaching its `*.lab.chasnelson.co.uk` hostnames).
- oterm: installed via `uv tool install oterm`, not `paru` (so it won't show up in the package table above) — chosen over the AUR package specifically to avoid depending on that maintainer keeping pace with oterm's fast upstream release cadence. This is the primary interface's terminal-side half — see [Primary interface](../core/README.md#primary-interface-oterm--open-webui) for the full reasoning, including the phone-side half (Open WebUI).

## Notes to self

- Remember that symlinks should be relative to ~

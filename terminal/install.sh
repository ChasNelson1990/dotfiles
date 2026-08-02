#! /bin/sh

# Fail loudly if $0 doesn't resolve to this file (e.g. piped into a shell
# or sourced) -- otherwise ROOT silently falls back to $HOME and every
# symlink below gets created wrong.
ROOT="$( dirname "$( readlink -f "$0" )" )"
if [ ! -f "$ROOT/install.sh" ]; then
  echo "install.sh: can't find its own repo checkout (ROOT='$ROOT'). Run it directly, e.g. './install.sh'." >&2
  exit 1
fi

# pacman/paru need this before any package installs below
sudo ln -sf "$ROOT/pacman.conf" /etc/pacman.conf

# clone $1 into $2, or pull if it's already there -- keeps re-runs quiet
clone_or_pull() {
  if [ -e "$2/.git" ] && git -C "$2" rev-parse --git-dir >/dev/null 2>&1; then
    git -C "$2" pull --ff-only || exit 1
  elif [ -e "$2" ]; then
    echo "clone_or_pull: $2 exists but isn't a git checkout" >&2
    exit 1
  else
    git clone "$1" "$2" || exit 1
  fi
}

# install latest paru
mkdir -p "$HOME/builds/"
clone_or_pull https://aur.archlinux.org/paru.git "$HOME/builds/paru"
cd "$HOME/builds/paru"
makepkg -si
cd "$HOME"

# upgrade current system
paru
# install 3D graphics and printing tools
paru -S openscad
# install audio tools
paru -S audacity pipewire pipewire-audio pipewire-alsa pipewire-jack pipewire-pulse pipewire-v4l2 wireplumber
# install comms tools
paru -S signal-desktop slack-desktop telegram-desktop
# install devOps tools
paru -S dbeaver docker docker-compose docker-buildx minikube kubectl postman-bin
# install office tools
paru -S hunspell-en_gb libreoffice-fresh-en-gb qpdf xournalpp
# install fonts
paru -S otf-monaspace-nerd
# install system gui
paru -S autorandr betterlockscreen i3-wm i3blocks i3status-rust i3wsr redshift rofi rofi-vscode-mode wired xorg-xinit xorg-server xorg-xsetroot
paru -S nordzy-cursors nordzy-icon-theme
# install image viewing and editing tools
paru -S darktable feh gimp graphicsmagick inkscape
# install browsers
paru -S chromium firefox firefox-i18n-en-gb google-chrome
# install monitors
paru -S bottom cpupower hddtemp htop lm_sensors powertop procs battop upower
# install network tools
paru -S bandwhich bluez-utils clamav curlie firewalld proton-pass-cli-bin proton-vpn-cli networkmanager python-fangfrisch tailscale
paru -Rcnsu dhcpcd netctl
# install programming languages and IDEs
paru -S nvm pyenv python-pipenv r texlive uv visual-studio-code-bin
# install databases
paru -S postgresql
# install shell tools
paru -S alacritty direnv mcfly oh-my-zsh-git starship tealdeer
# install file storage tools
paru -S duf dust exfat-utils ntfs-3g plocate ranger rclone zip
# ranger preview dependencies (images, video thumbnails, office documents)
paru -S ueberzugpp ffmpegthumbnailer odt2txt
# install system tools
paru -S bat brightnessctl eza fd fwupd ripgrep sd zoxide
# install utilities
paru -S android-file-transfer borg flameshot fprintd gnome-keyring kalu less libsecret libfprint macchina transmission-gtk udiskie
# install version control
paru -S git git-lfs github-cli
# install video tools
paru -S obs-studio shotcut v4l-utils vlc

# locale (needed for i3 kbd control)
sudo localectl --no-convert set-x11-keymap gb numpad:microsoft

# ensure ~/.ssh exists
mkdir -p "$HOME/.ssh"

# create symlinks for files
ln -sf "$ROOT/.xinitrc" "$HOME/.xinitrc"
ln -sf "$ROOT/.zshrc" "$HOME/.zshrc"
ln -sf "$ROOT/.zlogin" "$HOME/.zlogin"

mkdir -p "$HOME/.config/betterlockscreen"
ln -sf "$ROOT/config/betterlockscreen/betterlockscreenrc" "$HOME/.config/betterlockscreen/betterlockscreenrc"
ln -sf "$ROOT/config/betterlockscreen/custom-pre.sh" "$HOME/.config/betterlockscreen/custom-pre.sh"
ln -sf "$ROOT/config/betterlockscreen/custom-post.sh" "$HOME/.config/betterlockscreen/custom-post.sh"
sudo ln -sf "$ROOT/config/betterlockscreen/betterlockscreen@.service" /usr/lib/systemd/system/betterlockscreen@.service  # changes unit type to forking
sudo systemctl daemon-reload
sudo systemctl enable --now betterlockscreen@$USER

ln -sf "$ROOT/config/starship.toml" "$HOME/.config/starship.toml"

mkdir -p "$HOME/.config/alacritty"
ln -sf "$ROOT/config/alacritty/alacritty.toml" "$HOME/.config/alacritty/alacritty.toml"

mkdir -p "$HOME/.config/Code/User"
ln -sf "$ROOT/config/Code/User/settings.json" "$HOME/.config/Code/User/settings.json"
ln -sf "$ROOT/config/Code/User/keybindings.json" "$HOME/.config/Code/User/keybindings.json"

mkdir -p "$HOME/.config/wired"
ln -sf "$ROOT/config/wired/wired.ron" "$HOME/.config/wired/wired.ron"

mkdir -p "$HOME/.config/i3"
ln -sf "$ROOT/config/i3/config" "$HOME/.config/i3/config"

mkdir -p "$HOME/.config/i3status-rs"
ln -sf "$ROOT/config/i3status-rs/config.toml" "$HOME/.config/i3status-rs/config.toml"

mkdir -p "$HOME/.config/i3wsr"
ln -sf "$ROOT/config/i3wsr/config.toml" "$HOME/.config/i3wsr/config.toml"

ln -sf "$ROOT/config/autorandr" "$HOME/.config/autorandr"

mkdir -p "$HOME/.config/radian"
ln -sf "$ROOT/config/radian/profile" "$HOME/.config/radian/profile"

mkdir -p "$HOME/.config/ranger"
ln -sf "$ROOT/config/ranger/commands.py" "$HOME/.config/ranger/commands.py"
ln -sf "$ROOT/config/ranger/rc.conf" "$HOME/.config/ranger/rc.conf"
ln -sf "$ROOT/config/ranger/rifle.conf" "$HOME/.config/ranger/rifle.conf"
ln -sf "$ROOT/config/ranger/scope.sh" "$HOME/.config/ranger/scope.sh"

mkdir -p "$HOME/.config/redshift"
ln -sf "$ROOT/config/redshift/redshift.conf" "$HOME/.config/redshift/redshift.conf"

mkdir -p "$HOME/.config/rofi"
ln -sf "$ROOT/config/rofi/config.rasi" "$HOME/.config/rofi/config.rasi"
ln -sf "$ROOT/config/rofi/nord.rasi" "$HOME/.config/rofi/nord.rasi"

mkdir -p "$HOME/.config/macchina"
ln -sf "$ROOT/config/macchina/macchina.conf" "$HOME/.config/macchina/macchina.conf"

# enable backup service
# note this will only work if the harddrive is plugged in
#mkdir -p ~/.config/systemd/user
#ln -sf $ROOT/config/systemd/user/borg_cjn-bak.service ~/.config/systemd/user/borg_cjn-bak.service
#mkdir -p ~/.local/bin
#ln -sf $ROOT/local/bin/borg_cjn-bak.sh ~/.local/bin/borg_cjn-bak.sh
#systemctl enable --now --user borg_cjn-bak.service

# install custom packages
# cd otf-sansguilt
# makepkg -si

# install oterm (uv tool, not paru -- avoids depending on the AUR
# package keeping pace with oterm's fast upstream release cadence)
uv tool install oterm
# uv installs to ~/.local/bin, which .zshrc already puts on PATH for future
# shells -- export it here too so oterm is discoverable for the rest of
# this script run, in this same non-login shell
export PATH="$HOME/.local/bin:$PATH"

# install oh-my-zsh plugins
clone_or_pull https://github.com/zsh-users/zsh-autosuggestions "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions"
clone_or_pull https://github.com/zsh-users/zsh-syntax-highlighting "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting"
clone_or_pull https://github.com/lukechilds/zsh-nvm "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-nvm"
clone_or_pull https://github.com/davidparsson/zsh-pyenv-lazy.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/pyenv-lazy"

# update AV and firewall
sudo ln -sf "$ROOT/config/clamav/clamd.conf" /etc/clamav/clamd.conf
sudo ln -sf "$ROOT/config/clamav/freshclam.conf" /etc/clamav/freshclam.conf
sudo mkdir -p /etc/systemd/system/clamav-clamonacc.service.d
sudo ln -sf "$ROOT/config/clamav/fdpass.conf" /etc/systemd/system/clamav-clamonacc.service.d/fdpass.conf
sudo ln -sf "$ROOT/config/clamav/virus-event.bash" /etc/clamav/virus-event.bash
sudo chmod +x /etc/clamav/virus-event.bash
sudo systemctl stop clamav-freshclam.service
sudo freshclam
sudo systemctl daemon-reload
sudo systemctl enable --now clamav-freshclam.service
# if the following line fails, add --force
sudo -u clamav /usr/bin/fangfrisch --conf /etc/fangfrisch/fangfrisch.conf initdb
sudo systemctl enable --now fangfrisch.timer
sudo systemctl enable --now clamav-daemon.service
sudo systemctl enable --now clamav-clamonacc.service
sudo systemctl enable --now firewalld.service
sudo systemctl enable --now clamav-freshclam-once.timer
sudo systemctl enable --now clamav-unofficial-sigs.timer

# enable CPU power management
sudo ln -sf "$ROOT/cpupower" /etc/default/cpupower
sudo systemctl enable --now cpupower.service

# enable power management
# clean up TLP if previously installed (conflicts with power-profiles-daemon)
if pacman -Q tlp >/dev/null 2>&1; then
  sudo systemctl disable --now tlp.service
  sudo rm -f /etc/tlp.d/01-custom-tlp.conf
  paru -Rn tlp
fi
# power-profiles-daemon handles AC/battery performance profiles (replaces TLP)
# installed here (after TLP cleanup) to avoid pacman conflict if TLP was present
paru -S power-profiles-daemon
sudo systemctl enable --now power-profiles-daemon.service
# upower triggers hibernate at 1% battery
sudo install -Dm 0644 "$ROOT/etc/UPower/UPower.conf" /etc/UPower/UPower.conf
sudo systemctl enable upower.service
sudo systemctl restart upower.service
# NOTE: hibernate requires the swap partition UUID in the kernel cmdline.
# Add to /boot/loader/entries/arch.conf:
#   options ... resume=UUID=<swap-partition-uuid>
# Find the UUID with: lsblk -o NAME,UUID,FSTYPE | grep swap

# enable networking
sudo systemctl enable --now NetworkManager.service
sudo systemctl enable --now bluetooth.service
sudo systemctl enable --now tailscaled.service
# NOTE: joining the tailnet needs an interactive browser login — run manually:
#   sudo tailscale up

# enable docker
sudo systemctl enable --now docker.service

# enable audio services
systemctl enable --now --user wireplumber.service
systemctl enable --now --user pipewire.socket
systemctl enable --now --user pipewire-pulse.socket

# link gtk and cursor themes
ln -sf "$ROOT/gtkrc-2.0" "$HOME/.gtkrc-2.0"
mkdir -p "$HOME/.config/gtk-3.0"
ln -sf "$ROOT/config/gtk-3.0/settings.ini" "$HOME/.config/gtk-3.0/settings.ini"
ln -sf "$ROOT/icons" "$HOME/.icons"

# install vscode extensions
xargs -n 1 code --install-extension < "$ROOT/config/Code/extensions.txt"

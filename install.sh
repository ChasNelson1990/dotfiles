#! /bin/sh

# install latest paru
mkdir ~/builds/
cd ~/builds/
git clone https://aur.archlinux.org/paru.git
cd paru
makepkg -si
cd ~

# upgrade current system
paru
# install 3D graphics and printing tools
paru -S blender	openscad
# install audio tools
paru -S audacity pipewire pipewire-audio pipewire-alsa pipewire-jack pipewire-pulse pipewire-v4l2 wireplumber
# install comms tools
paru -S signal-desktop skypeforlinux-stable-bin slack-desktop telegram-desktop
# install devOps tools
paru -S aws-cli-v2 azure-cli dbeaver docker docker-compose docker-buildx minikube kubectl postman-bin
# install office tools
paru -S hunspell-en_GB libreoffice-fresh-en-gb mailspring qpdf xournalpp
# install fonts
paru -S otf-monaspace-nerd
# install system gui
paru -S autorandr betterlockscreen i3-layouts i3-wm i3blocks i3status-rust i3wsr redshift rofi rofi-vscode-mode wired-git xorg-xinit xorg-server xorg-xsetroot
paru -S nordzy-cursors nordzy-icon-theme lxappearance
# install image viewing and editing tools
paru -S darktable feh gimp graphics-magick inkscape
# install browsers
paru -S chromium firefox firefox-i18n-en-gb google-chrome
# install monitors
paru -S bottom cpupower hddtemp htop Iio-sensor-proxy lm_sensors powertop procs battop tlp
# install network tools
paru -S bandwhich clamav curlie firewalld mullvad-vpn-bin networkmanager python-fangfrisch
# paru -Rcnsu dhcpcd netctl
# install programming languages and IDEs
paru -S nvm pyenv r texlive visual-studio-code-bin
# install shell tools
paru -S alacritty direnv mcfly oh-my-zsh-git starship tealdeer
# install file storage tools
paru -S duf dust exfat-utils mlocate ntfs-3g ranger zip
# install system tools
paru -S bat brightnessctl exa fd fwupd ripgrep sd zoxide
# install utilities
paru -S android-file-transfer borg flameshot fprintd gnome-keyring kalu less libfprint macchina transmission-gtk
# install version control
paru -S git git-lfs github-cli
# install video tools
paru -S obs-studio shotcut v4l-utils vlc

# locale (needed for i3 kbd control)
sudo localectl --no-convert set-x11-keymap gb numpad:microsoft

# ensure ~/.ssh exists
mkdir -p ~/.ssh

ROOT="$( dirname $( readlink -f $0 ) )"
# create symlinks for files
ln -sf $ROOT/.xinitrc ~/.xinitrc
ln -sf $ROOT/.zshrc ~/.zshrc
ln -sf $ROOT/.zlogin ~/.zlogin

ln -sf $ROOT/config/betterlockscreenrc ~/.config/betterlockscreenrc

ln -sf $ROOT/config/starship.toml ~/.config/starship.toml

mkdir -p ~/.config/alacritty
ln -sf $ROOT/config/alacritty/alacritty.yml ~/.config/alacritty/alacritty.yml

mkdir -p ~/.config/Code/User
ln -sf $ROOT/config/Code/User/settings.json ~/.config/Code/User/settings.json
ln -sf $ROOT/config/Code/User/keybindings.json ~/.config/Code/User/keybindings.json

mkdir -p ~/.config/wired
ln -sf $ROOT/config/wired/wired.ron ~/.config/wired/wired.ron

mkdir -p ~/.config/i3
ln -sf $ROOT/config/i3/config ~/.config/i3/config

mkdir -p ~/.config/i3status-rs
ln -sf $ROOT/config/i3status-rs/config.toml ~/.config/i3status-rs/config.toml

mkdir -p ~/.config/i3wsr
ln -sf $ROOT/config/i3wsr/config.toml ~/.config/i3wsr/config.toml

mkdir -p ~/.config/ranger
ln -sf $ROOT/config/ranger/commands.py ~/.config/ranger/commands.py
ln -sf $ROOT/config/ranger/rc.conf ~/.config/ranger/rc.conf
ln -sf $ROOT/config/ranger/rifle.conf ~/.config/ranger/rifle.conf
ln -sf $ROOT/config/ranger/scope.sh ~/.config/ranger/scope.sh

mkdir -p ~/.config/redshift
ln -sf $ROOT/config/redshift/redshift.conf ~/.config/redshift/redshift.conf

mkdir -p ~/.config/rofi
ln -sf $ROOT/config/rofi/config.rasi ~/.config/rofi/config.rasi
ln -sf $ROOT/config/rofi/nord.rasi ~/.config/rofi/nord.rasi

mkdir -p ~/.config/macchina
sudo ln -sf $ROOT/config/macchina/macchina.conf ~/.config/macchina/macchina.conf

# enable backup service
# note this will only work if the harddrive is plugged in
mkdir -p ~/.config/systemd/user
ln -sf $ROOT/config/systemd/user/borg_cjn-bak.service ~/.config/systemd/user/borg_cjn-bak.service
mkdir -p ~/.local/bin
ln -sf $ROOT/local/bin/borg_cjn-bak.sh ~/.local/bin/borg_cjn-bak.sh
systemctl enable --now --user borg_cjn-bak.service

# install custom packages
cd otf-sansguilt
makepkg -si

# install oh-my-zsh plugins
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
git clone https://github.com/lukechilds/zsh-nvm ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-nvm
git clone https://github.com/davidparsson/zsh-pyenv-lazy.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/pyenv-lazy

# update AV and firewall
sudo ln -sf $ROOT/config/clamav/clamd.conf /etc/clamav/clamd.conf
sudo ln -sf $ROOT/config/clamav/freshclam.conf /etc/clamav/freshclam.conf
sudo systemctl stop clamav-freshclam.service
sudo freshclam
sudo systemctl enable --now clamav-freshclam.service
# if the following line fails, add --force
sudo -u clamav /usr/bin/fangfrisch --conf /etc/fangfrisch/fangfrisch.conf initdb
sudo systemctl enable --now fangfrisch.timer
sudo systemctl enable --now clamav-daemon.service
sudo systemctl enable --now clamav-clamonacc.service
sudo systemctl enable --now firewalld.service

# enable CPU power management
sudo ln -sf $ROOT/cpupower /etc/default/cpupower
sudo systemctl enable --now cpupower.service

# enable power management
sudo ln -sf $ROOT/01-custom-tlp.conf /etc/tlp.d/01-custom-tlp.conf
sudo systemctl enable --now tlp.service

# enable networking
sudo systemctl enable --now NetworkManager.service
sudo systemctl enable --now bluetooth.service

# enable docker
sudo systemctl enable --now docker.service

# enable audio services
systemctl enable --now --user wireplumber.service
systemctl enable --now --user pipewire.socket
systemctl enable --now --user pipewire-pulse.socket

# link gtk and cursor themes
sudo ln -sf $ROOT//gtkrc-2.0 ~/.gtkrc-2.0
mkdir -p ~/.config/gtk-3.0
sudo ln -sf $ROOT/config/gtk-3.0/settings.ini ~/.config/gtk-3.0/settings.ini
sudo ln -sf $ROOT/icons ~/.icons

# install vscode extensions
cat $ROOT/config/Code/extensions.txt | xargs -n 1 code --install-extension

#! /bin/bash

pikaur -Syu --needed - < pkglist.txt

ROOT="$( dirname $( readlink -f $0 ) )"


# create symlinks for files
# general
ln -sf $ROOT/.zshrc ~/.zshrc
ln -sf $ROOT/.zprofile ~/.zprofile
mkdir -p ~/.config/alacritty
ln -sf $ROOT/config/alacritty/alacritty.yml ~/.config/alacritty/alacritty.yml
mkdir -p ~/.config/Code/User
ln -sf $ROOT/config/Code/User/settings.json ~/.config/Code/User/settings.json
mkdir -p ~/.config/ranger
ln -sf $ROOT/config/ranger/commands.py ~/.config/ranger/commands.py
ln -sf $ROOT/config/ranger/rc.conf ~/.config/ranger/rc.conf
ln -sf $ROOT/config/ranger/rifle.conf ~/.config/ranger/rifle.conf
ln -sf $ROOT/config/ranger/scope.sh ~/.config/ranger/scope.sh
mkdir -p ~/.config/redshift
ln -sf $ROOT/config/redshift/redshift.conf ~/.config/redshift/redshift.conf
ln -sf $ROOT/config/artha.conf ~/.config/artha.conf
sudo ln -sf $ROOT/config/clamav/clamd.conf /etc/clamav/clamd.conf
sudo ln -sf $ROOT/config/clamav/freshclam.conf /etc/clamav/freshclam.conf

# wayland-based sway
mkdir -p ~/.config/kanshi
ln -sf $ROOT/config/kanshi/config ~/.config/kanshi/config
mkdir -p ~/.config/mako
ln -sf $ROOT/config/mako/config ~/.config/mako/config
mkdir -p ~/.config/sway/config.d
ln -sf $ROOT/config/sway/config.d/10-systemd ~/.config/sway/config.d/10-systemd
ln -sf $ROOT/config/sway/config ~/.config/sway/config
mkdir -p ~/.config/swaylock
ln -sf $ROOT/config/swaylock/config ~/.config/swaylock/config
mkdir -p ~/.config/waybar
ln -sf $ROOT/config/waybar/config ~/.config/waybar/config
ln -sf $ROOT/config/waybar/style.css ~/.config/waybar/style.css


# alternative X-based i3
ln -sf $ROOT/.xinitrc ~/.xinitrc
ln -sf $ROOT/.Xresources ~/.Xresources
mkdir -p ~/.config/i3
ln -sf $ROOT/config/i3/config ~/.config/i3/config
mkdir -p ~/.config/rofi
ln -sf $ROOT/config/rofi/config.rasi ~/.config/rofi/config.rasi
ln -sf $ROOT/config/rofi/nord.rasi ~/.config/rofi/nord.rasi

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

# update AV and firewall
freshclam
sudo systemctl enable --now clamav-freshclam.service
sudo -u clamav /usr/bin/fangfrisch --conf /etc/fangfrisch/fangfrisch.conf initdb
sudo systemctl enable --now fangfrisch.timer
sudo systemctl enable --now clamav-daemon.service
sudo systemctl enable --now clamav-clamonacc.service
sudo systemctl enable --now firewalld.service

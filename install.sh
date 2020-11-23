#! /bin/bash

ROOT="$( dirname $( readlink -f $0 ) )"


# create symlinks for files
ln -sf $ROOT/.zshrc ~/.zshrc
ln -sf $ROOT/.zprofile ~/.zprofile
ln -sf $ROOT/.Xresources ~/.Xrresources
mkdir -p ~/.config/Code/User
ln -sf $ROOT/config/Code/User/settings.json ~/.config/Code/User/settings.json
mkdir -p ~/.config/kanshi
ln -sf $ROOT/config/kanshi/config ~/.config/kanshi/config
mkdir -p ~/.config/mako
ln -sf $ROOT/config/mako/config ~/.config/mako/config
mkdir -p ~/.config/ranger
ln -sf $ROOT/config/ranger/commands.py ~/.config/ranger/commands.py
ln -sf $ROOT/config/ranger/rc.conf ~/.config/ranger/rc.conf
ln -sf $ROOT/config/ranger/rifle.conf ~/.config/ranger/rifle.conf
ln -sf $ROOT/config/ranger/scope.sh ~/.config/ranger/scope.sh
mkdir -p ~/.config/redshift
ln -sf $ROOT/config/redshift/redshift.conf ~/.config/redshift/redshift.conf
mkdir -p ~/.config/sway/config.d
ln -sf $ROOT/config/sway/config.d/10-systemd ~/.config/sway/config.d/10-systemd
ln -sf $ROOT/config/sway/config ~/.config/sway/config
mkdir -p ~/.config/swaylock
ln -sf $ROOT/config/swaylock/config ~/.config/swaylock/config
mkdir -p ~/.config/systemd/user
ln -sf $ROOT/config/systemd/user/borg_cjn-bak.service ~/.config/systemd/user/borg_cjn-bak.service
mkdir -p ~/.config/waybar
ln -sf $ROOT/config/waybar/config ~/.config/waybar/config
ln -sf $ROOT/config/waybar/style.css ~/.config/waybar/style.css
ln -sf $ROOT/config/artha.conf ~/.config/artha.conf
mkdir -p ~/.local/bin
ln -sf $ROOT/local/bin/borg_cjn-bak.sh ~/.local/bin/borg_cjn-bak.sh

# enable backup service
# note this will only work if the harddrive is plugged in
systemctl enable --now --user borg_cjn-bak.service

# install custom packages
cd otf-sansguilt
makepkg -si
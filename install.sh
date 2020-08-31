#! /bin/bash

ROOT="$( dirname $( readlink -f $0 ) )"

# create symlinks for files
# note: assumes folders already exist
ln -sf $ROOT/.zshrc ~/.zshrc
ln -sf $ROOT/.zlogin ~/.zlogin
ln -sf $ROOT/.Xresources ~/.Xrresources
ln -sf $ROOT/config/albert/albert.conf ~/.config/albert/albert.conf
ln -sf $ROOT/config/Code/User/settings.json ~/.config/Code/User/settings.json
ln -sf $ROOT/config/kanshi/config ~/.config/kanshi/config
ln -sf $ROOT/config/kitty/kitty.conf ~/.config/kitty/kitty.conf
ln -sf $ROOT/config/mako/config ~/.config/mako/config
ln -sf $ROOT/config/ranger/commands.py ~/.config/ranger/commands.py
ln -sf $ROOT/config/ranger/rc.conf ~/.config/ranger/rc.conf
ln -sf $ROOT/config/ranger/rifle.conf ~/.config/ranger/rifle.conf
ln -sf $ROOT/config/ranger/scope.sh ~/.config/ranger/scope.sh
ln -sf $ROOT/config/redshift/redshift.conf ~/.config/redshift/redshift.conf
ln -sf $ROOT/config/sway/config.d/10-systemd ~/.config/sway/config.d/10-systemd
ln -sf $ROOT/config/sway/config ~/.config/sway/config
ln -sf $ROOT/config/swaylock/config ~/.config/swaylock/config
ln -sf $ROOT/config/systemd/user/borg_cjn-bak.service ~/.config/systemd/user/borg_cjn-bak.service
ln -sf $ROOT/config/waybar/config ~/.config/waybar/config
ln -sf $ROOT/config/waybar/style.css ~/.config/waybar/style.css
ln -sf $ROOT/config/artha.conf ~/.config/artha.conf
ln -sf $ROOT/local/bin/borg_cjn-bak.sh ~/.local/bin/borg_cjn-bak.sh

# enable backup service
# note this will only work if the harddrive is plugged in
systemctl enable --now --user borg_cjn-bak.service

# install custom packages
cd otf-sansguilt
makepkg -si
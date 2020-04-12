#! /bin/bash

# create symlinks for files
# note: assumes folders already exist
ln -s ./.zshrc ~/.zshrc
ln -s ./config/albert/albert.conf ~/.config/albert/albert.conf
ln -s ./config/kanshi/config ~/.config/kanshi/config
ln -s ./config/kitty/kitty.conf ~/.config/kitty/kitty.conf
ln -s ./config/mako/config ~/.config/mako/config
ln -s ./config/redshift/redshift.conf ~/.config/redshift/redshift.conf
ln -s ./config/sway/config.d/10-systemd ~/.config/sway/config.d/10-systemd
ln -s ./config/sway/config ~/.config/sway/config
ln -s ./config/systemd/user/borg_cjn-bak.service ~/.config/systemd/user/borg_cjn-bak.service
ln -s ./config/waybar/config ~/.config/waybar/config
ln -s ./config/waybar/style.css ~/.config/waybar/style.css
ln -s ./config/artha.conf ~/.config/artha.conf
ln -s ./local/bin/borg_cjn-bak.sh ~/.local/bin/borg_cjn-bak.sh
systemctl enable --now --user borg_cjn-bak.service
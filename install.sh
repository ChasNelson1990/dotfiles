#! /bin/bash

# pikaur -Syu --needed - < pkglist.txt

ROOT="$( dirname $( readlink -f $0 ) )"

# locale (needed for i3 kbd control)
sudo localectl --no-convert set-x11-keymap gb numpad:microsoft

# create symlinks for files
# general
ln -sf $ROOT/.xinitrc ~/.xinitrc
ln -sf $ROOT/.zshrc ~/.zshrc
ln -sf $ROOT/.zlogin ~/.zlogin

ln -sf $ROOT/config/artha.conf ~/.config/artha.conf
ln -sf $ROOT/config/betterlockscreenrc ~/.config/betterlockscreenrc
ln -sf $ROOT/config/starship.toml ~/.config/starship.toml
ln -sf $ROOT/config/zen.starship.toml ~/.config/zen.starship.toml

mkdir -p ~/.config/alacritty
ln -sf $ROOT/config/alacritty/alacritty.yml ~/.config/alacritty/alacritty.yml

mkdir -p ~/.config/Code/User
ln -sf $ROOT/config/Code/User/settings.json ~/.config/Code/User/settings.json
ln -sf $ROOT/config/Code/User/keybindings.json ~/.config/Code/User/keybindings.json

mkdir -p ~/.config/wired
ln -sf $ROOT/config/wired/wired.ron ~/.config/wired/wired.ron

mkdir -p ~/.config/i3
ln -sf $ROOT/config/i3/config ~/.config/i3/config

mkdir -p ~/.config/i3status
ln -sf $ROOT/config/i3status/config ~/.config/i3status/config

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
git clone https://github.com/lukechilds/zsh-nvm ${ZSH_CUSTOM:~/.oh-my-zsh/custom}/plugins/zsh-nvm
git clone https://github.com/davidparsson/zsh-pyenv-lazy.git  ${ZSH_CUSTOM:~/.oh-my-zsh/custom}/plugins/pyenv-lazy

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

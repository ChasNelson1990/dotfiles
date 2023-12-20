# zmodload zsh/zprof

# oh-my-zsh configuration root and custom folder
ZSH=/usr/share/oh-my-zsh
ZSH_CUSTOM=~/.oh-my-zsh/custom

# theme
ZSH_THEME=""

# Use hyphen-insensitive completion.
HYPHEN_INSENSITIVE="true"

# Disable bi-weekly auto-update checks.
DISABLE_AUTO_UPDATE="true"

# Command auto-correction.
# ENABLE_CORRECTION="true"

# Display red dots whilst waiting for completion.
COMPLETION_WAITING_DOTS="true"

# Command execution time stamp
HIST_STAMPS="yyyy-mm-dd"

# Settings for zsh-nvm
NVM_LAZY_LOAD=true
NVM_COMPLETION=true
NVM_AUTO_USE=true
NVM_LAZY_LOAD_EXTRA_COMMANDS=('yarn')

# Plugins
# Standard plugins can be found in ~/.oh-my-zsh/plugins/*
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
plugins=(
    # bgnotify # Show notifications when a command finishes
    command-not-found # Show recommended installs from archpkg if command not found
    docker # Docker autocomplete
    docker-compose # Docker-compose autocomplete and aliases
    extract # easily extract archives
    gpg-agent # run gpg agent in background
    last-working-dir # Show last working directory and adds lwd for cd there
#    pyenv-lazy # lazy load pyenv to speed up load time
    zsh-nvm # load nvm, we can set lazy load to true
    safe-paste # Paste from clipboard without running code
    screen # title setter for screen
    ssh-agent # run ssh agent in background
    sudo # double esc for sudo
    zsh-autosuggestions # autosuggestions
    zsh-syntax-highlighting # syntax highlighting
)

# Utility aliases
# fix ls aliases by turning zsh colouring off
DISABLE_LS_COLORS="true"
alias ls="exa"

alias cat="bat"
alias top="btm"
alias htop="btm"
alias find="fd"
alias grep="rg"
alias ps="procs"
# alias sed="sd"
alias curl="curlie"
alias du="dust"
alias df="duf"

# autosuggestions
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#ffffff"

ZSH_CACHE_DIR=$HOME/.cache/oh-my-zsh
if [[ ! -d $ZSH_CACHE_DIR ]]; then
  mkdir $ZSH_CACHE_DIR
fi

# Socket for SSH agent
#if ! pgrep -u "$USER" ssh-agent > /dev/null; then
#    ssh-agent > "$XDG_RUNTIME_DIR/ssh-agent.env"
#fi
#if [[ ! "$SSH_AUTH_SOCK" ]]; then
#    eval "$(<"$XDG_RUNTIME_DIR/ssh-agent.env")"
#fi

# path for poetry
export PATH="$HOME/.poetry/bin:$HOME/.local/bin:$PATH"

# path for pyenv
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"

# pipenv
export PIPENV_VENV_IN_PROJECT=1 

# prevent nested ranger instances
ranger() {
    if [ -z "$RANGER_LEVEL" ]; then
        /usr/bin/ranger "$@"
    else
        exit
    fi
}

export GPG_TTY=$(tty)

# activate oh-my-zsh
source $ZSH/oh-my-zsh.sh

# activate mcFly
eval "$(mcfly init zsh)"

# activate starship
eval "$(starship init zsh)"

# run macchina
macchina

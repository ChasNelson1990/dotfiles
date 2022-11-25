zmodload zsh/zprof

## oh-my-zsh configuration
# Path to your oh-my-zsh installation.
ZSH=/usr/share/oh-my-zsh/

# theme
ZSH_THEME=""

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
DISABLE_AUTO_UPDATE="true"

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS=true

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
HIST_STAMPS="yyyy-mm-dd"

# Would you like to use another custom folder than $ZSH/custom?
ZSH_CUSTOM=~/.oh-my-zsh/custom

# Which plugins would you like to load?
# Standard plugins can be found in ~/.oh-my-zsh/plugins/*
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
    bgnotify # Show notifications when a command finishes
    command-not-found # Show recommended installs from archpkg if command not found
    docker # Docker autocomplete
    docker-compose # Docker-compose autocomplete and aliases
    extract # easily extract archives
    gpg-agent # run gpg agent in background
    last-working-dir # Show last working directory and adds lwd for cd there
    pyenv-lazy # lazy load pyenv to speed up load time
    safe-paste # Paste from clipboard without running code
    screen # title setter for screen
    ssh-agent # run ssh agent in background
    sudo # double esc for sudo
    zsh-autosuggestions # autosuggestions
    zsh-syntax-highlighting # syntax highlighting
)

## Rust utilities
# fix ls aliases by turning zsh colouring off
export DISABLE_LS_COLORS="true"
# aliases
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
if ! pgrep -u "$USER" ssh-agent > /dev/null; then
    ssh-agent > "$XDG_RUNTIME_DIR/ssh-agent.env"
fi
if [[ ! "$SSH_AUTH_SOCK" ]]; then
    eval "$(<"$XDG_RUNTIME_DIR/ssh-agent.env")"
fi

export PATH="$HOME/.poetry/bin:$HOME/.local/bin:$PATH"

# prevent nested ranger instances
ranger() {
    if [ -z "$RANGER_LEVEL" ]; then
        /usr/bin/ranger "$@"
    else
        exit
    fi
}

export GPG_TTY=$(tty)

# starship mode switching aliases
alias zenmode="export STARSHIP_CONFIG=~/.config/zen.starship.toml"
alias unzenmode="export STARSHIP_CONFIG=~/.config/starship.toml"

# activate oh-my-zsh
source $ZSH/oh-my-zsh.sh

# activate mcFly
eval "$(mcfly init zsh)"

# activate starship
eval "$(starship init zsh)"

# run macchina
macchina

export PATH="$HOME/.poetry/bin:$PATH"

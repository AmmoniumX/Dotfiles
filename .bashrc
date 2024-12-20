#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Load other scripts
if [[ ! -f ~/.bash-preexec.sh ]]; then
    echo ".bash-preexec.sh not found, installing"
    curl https://raw.githubusercontent.com/rcaloras/bash-preexec/master/bash-preexec.sh -o ~/.bash-preexec.sh
fi
source ~/.bash-preexec.sh
#if [[ ! -f ~/.local/share/blesh/ble.sh ]]; then
#    echo "ble.sh not found, Installing"
#    git clone --recursive https://github.com/akinomyoga/ble.sh.git /tmp/ble.sh > /dev/null
#    (cd /tmp/ble.sh && make install PREFIX=~/.local > /dev/null)
#    rm -rf /tmp/ble.sh
#fi
#source ~/.local/share/blesh/ble.sh

# Aliases
command -v eza &> /dev/null && alias ls='eza --color=auto' || alias ls='ls --color=auto'
alias ll='ls -l'
alias la='ls -a'
alias lla='ls -la'
command -v bat &> /dev/null && alias cat='bat --style=plain --paging=never'
command -v bat &> /dev/null && alias pcat='bat --style=plain --paging=always' || alias pcat='less'
alias mv='mv -iv'
alias cp='cp -riv'
alias grep='grep --color=auto'
alias more='LESS_IS_MORE=1 less'
if command -v aura &> /dev/null; then
    alias pacman='aura'
    alias sys-upgrade='aura -Syu && aura -Ayu'
fi
if command -v apt &> /dev/null; then
    alias sys-upgrade='sudo apt update && sudo apt upgrade'
fi
alias sourcerc='source ~/.bashrc'
alias pgrep='pgrep -a'
alias pkill='pkill -e'
alias make='make -j$(nproc)'
alias sctl='systemctl'
alias sctlu='systemctl --user'
alias jctl='journalctl'
alias jctlu='journalctl --user'

# Get public IP address
alias ipv4='curl -4 ip.me'
alias ipv6='curl -6 ip.me'

# Functions

# Print ls after cd on Starship
function cd() {
  if builtin cd "$@"; then
    # Capture ls output
    export _ls_output=$(script -q -c "eza --color=always" /dev/null)
  fi
}
# Register preexec hook
preexec() {
  unset _ls_output
}

function mkcd() { mkdir -p "$1" && cd "$1"; }
function cp-mkdir() { mkdir -p "$(dirname "$2")" && cp "$1" "$2"; }
function lfcd () {
    tmp="$(mktemp)"
    lf -last-dir-path="$tmp" "$@"
    if [ -f "$tmp" ]; then
        dir="$(cat "$tmp")"
        rm -f "$tmp"
        if [ -d "$dir" ]; then
            cd "$dir"
        fi
    fi
}

# Get local IP address, given interface name
function ipv4-dev() { 
    [[ -z "$1" ]] && { echo "Usage: ipv4-dev <interface>"; return 1; }
    ip addr show "$1" | grep 'inet ' | grep -v '127.0.0.1' | cut -d' ' -f6 | cut -d/ -f1;
}

function ipv6-dev() { 
    [[ -z "$1" ]] && { echo "Usage: ipv6-dev <interface>"; return 1; }
    ip addr show "$1" | grep 'inet6 ' | cut -d' ' -f6 | sed -n '1p' | cut -d/ -f1; 
}

# Pretty print json
function cat-json() {
    [[ -z "$1" ]] && { echo "Usage: cat-json <json file>"; return 1; }
    python -m json.tool "$1"
}


PS1='[\u@\h \W]\$ '

export EDITOR=nano

command -v starship &>/dev/null && eval "$(starship init bash)"
command -v fzf &>/dev/null && eval "$(fzf --bash)"
# Show current working directory on login
export _ls_output=$(script -q -c "eza --color=always" /dev/null)

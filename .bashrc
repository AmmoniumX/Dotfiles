#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Load other scripts
[[ -f ~/.bash-preexec.sh ]] && source ~/.bash-preexec.sh
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
command -v bat &> /dev/null && alias cat='bat -pp' || alias cat='cat'
alias mv='mv -nv'
alias cp='cp -rnv'
alias grep='grep --color=auto'
alias more='LESS_IS_MORE=1 less'
command -v aura &> /dev/null && alias pacman='aura' || alias pacman='pacman'
alias sys-upgrade='aura -Syu && aura -Ayu'
alias sourcerc='source ~/.bashrc'
alias pgrep='pgrep -a'
alias pkill='pkill -e'
alias make='make -j$(nproc)'
alias rm-whatif='ls -Ra'

# Get public IP address
alias ipv4='curl -4 ip.me'
alias ipv6='curl -6 ip.me'

# Functions

# Print ls after cd on Starship
export _ls_counter=0
function cd() {
  if builtin cd "$@"; then
    # ls
    export _ls_output=$(script -q -c "eza --color=always" /dev/null)
    # Reset the counter every time we cd
    _ls_counter=0
  fi
}
# Register preexec hook
preexec() {
  # Increment the command counter
  (( _ls_counter++ ))
  # Only unset _ls_output if this is the second command
  if [[ $_ls_counter -eq 1 ]]; then
    unset _ls_output
    # Reset the counter after unsetting
    _ls_counter=0
  fi
}

function mkcd() { mkdir "$1" && cd "$1"; }
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


PS1='[\u@\h \W]\$ '

export EDITOR=nano

command -v starship &>/dev/null && eval "$(starship init bash)"
command -v fzf &>/dev/null && eval "$(fzf --bash)"

#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Aliases
alias ls='eza --color=auto'
alias ll='eza -l'
alias la='eza -a'
alias lla='eza -la'
alias mv='mv -nv'
alias cp='cp -rnv'
alias grep='grep --color=auto'
alias more='LESS_IS_MORE=1 less'
alias pacman='aura'
alias sys-upgrade='aura -Syu && aura -Ayu'
alias sourcerc='source ~/.bashrc'
alias nanorc='nano ~/.bashrc'
alias track='tail -f'
alias pgrep='pgrep -a'
alias pkill='pkill -e'
alias make='make -j$(nproc)'
alias rm-whatif='ls -Ra'

# Get public IP address
alias ipv4='curl -4 ip.me'
alias ipv6='curl -6 ip.me'

# Functions
function mkcd() { mkdir "$1" && cd "$1"; }
function cd() {
  # Use the builtin `cd` to handle directory change and check if successful
  if builtin cd "$@"; then
    ls
  fi
}
function cp-mkdir() { mkdir -p "$(dirname "$2")" && cp "$1" "$2"; }

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

eval "$(starship init bash)"
eval "$(fzf --bash)"

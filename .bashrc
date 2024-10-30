#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Aliases
command -v eza &> /dev/null && alias ls='eza --color=auto' || alias ls='ls --color=auto'
alias ll='ls -l'
alias la='ls -a'
alias lla='ls -la'
command -v bat &> /dev/null && alias cat='bat -p' || alias cat='cat'
alias mv='mv -nv'
alias cp='cp -rnv'
alias grep='grep --color=auto'
alias more='LESS_IS_MORE=1 less'
command -v aura &> /dev/null && alias pacman='aura'
alias sys-upgrade='aura -Syu && aura -Ayu'
alias sourcerc='source ~/.bashrc'
alias nanorc='nano ~/.bashrc'
alias pgrep='pgrep -a'
alias pkill='pkill -e'
alias make='make -j$(nproc)'
alias rm-whatif='ls -Ra'

# Get public IP address
alias ipv4='curl -4 ip.me'
alias ipv6='curl -6 ip.me'

# Functions
function cd() {
  # Use the builtin `cd` to handle directory change and check if successful
  if builtin cd "$@"; then
    ls
  fi
}
function mkcd() { mkdir "$1" && cd "$1"; }
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

command -v starship &>/dev/null && eval "$(starship init bash)"
command -v fzf &>/dev/null && eval "$(fzf --bash)"

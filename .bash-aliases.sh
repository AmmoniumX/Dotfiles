# Aliases
command -v eza &> /dev/null && alias ls='eza --color=auto' || alias ls='ls --color=auto'
alias ll='ls -l'
alias la='ls -a'
alias lla='ls -la'
command -v batcat &> /dev/null && alias bat='batcat'
command -v bat &> /dev/null && alias cat='bat --style=plain --paging=never'
command -v bat &> /dev/null && alias less='bat --style=plain --paging=always'
alias mv='mv -iv'
alias cp='cp -riv'
alias grep='grep --color=auto'
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

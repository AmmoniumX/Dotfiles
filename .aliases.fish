# Aliases
if command -v eza &>/dev/null
    alias ls='eza --color=auto'
else
    alias ls='ls --color=auto'
end
abbr -a ll ls -l
abbr -a la ls -a
abbr -a lla ls -la
if command -v batcat &>/dev/null
    alias bat='batcat'
end
if command -v bat &>/dev/null
    alias cat='bat --style=plain --paging=never'
    alias less='bat --style=plain --paging=always'
end
alias mv='mv -iv'
alias cp='cp -riv'
alias grep='grep --color=auto'
if command -v paru &>/dev/null
    alias sys-upgrade='paru -Syu --repo && paru -Syu --aur --upgrademenu'
end
if command -v apt &>/dev/null
    alias sys-upgrade='sudo apt update && sudo apt upgrade'
end
alias sourcerc='source ~/.config/fish/config.fish'
alias pgrep='pgrep -a'
alias pkill='pkill -e'
alias make='make -j(nproc)'
abbr -a gcam git commit -am
abbr -a gs git status
alias paru-fzf="$HOME/Scripts/paru-fzf"

# Get public IP address
alias ipv4='curl -4 ip.me'
alias ipv6='curl -6 ip.me'

# Pretty print json
alias catj='python -m json.tool'

#
# ~/.bashrc
#

# ~/.bash-history settings
export HISTFILE=~/.bash_history
export HISTSIZE=10000
export HISTFILESIZE=20000
export HISTCONTROL=ignoredups:erasedups
export HISTTIMEFORMAT="%Y-%m-%d %H:%M:%S "
EDITOR=nvim
shopt -s histappend checkwinsize

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Append to PATH
export PATH="$PATH:$HOME/.cargo/bin"

# Load other scripts
source ~/.aliases.sh
source ~/.functions.sh

# Show current working directory on login
export _ls_output=$(eza --color=always --grid) # Works since eza v0.23.0

# Finish tty init
command -v starship &>/dev/null && eval "$(starship init bash)"
command -v fzf &>/dev/null && eval "$(fzf --bash)"
command -v direnv &>/dev/null && eval "$(direnv hook bash)"
command -v zoxide &>/dev/null && eval "$(zoxide init bash)"
[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"

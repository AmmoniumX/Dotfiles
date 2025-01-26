#
# ~/.bashrc
#

# ~/.bash-history settings
export HISTFILE=~/.bash_history
export HISTSIZE=10000
export HISTFILESIZE=20000
export HISTCONTROL=ignoredups:erasedups
export HISTTIMEFORMAT="%Y-%m-%d %H:%M:%S "
shopt -s histappend

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Load other scripts
source ~/.bash-aliases.sh
source ~/.bash-functions.sh

# Show current working directory on login
# export _ls_output=$(script -q -c "eza --color=always" /dev/null)
export _ls_output=$(eza --color=always)

# Finish tty init
PS1='[\u@\h \W]\$ '
export EDITOR=nano
command -v starship &>/dev/null && eval "$(starship init bash)"
command -v fzf &>/dev/null && eval "$(fzf --bash)"

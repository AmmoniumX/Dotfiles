#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# ~/.bash-history settings
export HISTFILE=~/.bash_history
export HISTSIZE=10000
export HISTFILESIZE=20000
export HISTCONTROL=ignoredups:erasedups
export HISTTIMEFORMAT="%Y-%m-%d %H:%M:%S "
shopt -s histappend checkwinsize


# Use bash-completion, if available, and avoid double-sourcing
[[ $PS1 &&
  ! ${BASH_COMPLETION_VERSINFO:-} &&
  -f /usr/share/bash-completion/bash_completion ]] &&
    . /usr/share/bash-completion/bash_completion

# Load other scripts
source ~/.aliases.sh
source ~/.functions.sh

# Finish tty init
command -v starship &>/dev/null && eval "$(starship init bash)"
command -v fzf &>/dev/null && eval "$(fzf --bash)"
command -v direnv &>/dev/null && eval "$(direnv hook bash)"
command -v zoxide &>/dev/null && eval "$(zoxide init bash)"

# ls on shell open
echo && ls

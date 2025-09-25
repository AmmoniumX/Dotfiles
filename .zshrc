# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000
EDITOR=nvim
setopt autocd beep extendedglob nomatch
bindkey -e
# End of lines configured by zsh-newuser-install
# # The following lines were added by compinstall
# zstyle :compinstall filename '/home/ammonium/.zshrc'
# 
# autoload -Uz compinit
# compinit
# # End of lines added by compinstall

# If not running interactively, don't do anything
# [[ $- != *i* ]] && return

# Append to PATH
export PATH="$PATH:$HOME/.cargo/bin"

# Load other scripts
source ~/.aliases.sh
source ~/.functions.sh

# Show current working directory on login
export _ls_output=$(eza --color=always --grid) # Works since eza v0.23.0

# Finish tty init
command -v starship &>/dev/null && eval "$(starship init zsh)"
command -v fzf &>/dev/null && eval "$(fzf --zsh)"
command -v direnv &>/dev/null && eval "$(direnv hook zsh)"
[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"


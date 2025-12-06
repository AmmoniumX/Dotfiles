# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000
EDITOR=nvim
setopt autocd beep extendedglob nomatch interactivecomments
bindkey -e

# End of lines configured by zsh-newuser-install
# # The following lines were added by compinstall
# zstyle :compinstall filename '/home/ammonium/.zshrc'

autoload -Uz compinit
compinit
# # End of lines added by compinstall

# 1. Home and End Keys (Go to beginning/end of line)
# These are often bound to ^[[H and ^[[F respectively, but can vary by terminal.
# The standard functions are beginning-of-line and end-of-line.
# Try these first (common for many terminals):
bindkey '\e[H' beginning-of-line
bindkey '\e[F' end-of-line

# 2. Ctrl-Left and Ctrl-Right (Word navigation)
# These are often bound to ^[[1;5D and ^[[1;5C respectively, but can vary.
# The standard functions are backward-word and forward-word.
# Try these first (common for many terminals):
bindkey '\e[1;5D' backward-word  # Ctrl-Left
bindkey '\e[1;5C' forward-word   # Ctrl-Right


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
command -v zoxide &>/dev/null && eval "$(zoxide init zsh)"
[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"
[ -f "$HOME/.env" ] && source "$HOME/.env"


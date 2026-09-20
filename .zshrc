# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000
setopt autocd beep extendedglob nomatch interactivecomments HIST_IGNORE_DUPS
bindkey -e

# End of lines configured by zsh-newuser-install
# # The following lines were added by compinstall
# zstyle :compinstall filename '/home/ammonium/.zshrc'

# Exit early if non-interactive session
[[ -o interactive ]] || return

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

# Load other scripts
source ~/.aliases.sh
source ~/.functions.sh

# Finish tty init
command -v starship &>/dev/null && eval "$(starship init zsh)"
command -v fzf &>/dev/null && eval "$(fzf --zsh)"
command -v direnv &>/dev/null && eval "$(direnv hook zsh)"
command -v zoxide &>/dev/null && eval "$(zoxide init zsh)"

# ls on shell open
if [[ -z $NO_STARTUP_LS ]]; then
  echo
  ls
fi

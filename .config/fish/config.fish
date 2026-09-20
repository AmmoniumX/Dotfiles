# Early exit if non-interactive
if not status is-interactive
  return
end

function cmd_exists
    type -q $argv[1]
end

# Init shell extensions
if cmd_exists starship
    starship init fish | source
end

if cmd_exists fzf
    fzf --fish | source
end

if cmd_exists direnv
    direnv hook fish | source
end

if cmd_exists zoxide
    zoxide init fish | source
end

# Load functions and aliases
source ~/.functions.fish
source ~/.aliases.fish

[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"
[ -f "$HOME/.env" ] && . "$HOME/.env"

# ls on shell open
if not set -q NO_STARTUP_LS
    echo
    ls
end

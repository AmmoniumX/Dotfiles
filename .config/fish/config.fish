# Load aliases and functions
source ~/.aliases.fish
source ~/.functions.fish

function cmd_exists
    type -q $argv[1]
end

export _ls_output=(eza --color=always --grid) # Works since eza v0.23.0

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

[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"
[ -f "$HOME/.env" ] && . "$HOME/.env"

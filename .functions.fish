# Shell Functions

# fish_preexec hook: reset ls-after-cd before each typed command
function __reset_ls_output --on-event fish_preexec
    set -e _ls_output
end

# Capture ls output whenever the working directory changes (cd, z, pushd, ...)
function __capture_ls_output --on-variable PWD
    status --is-command-substitution; and return
    set -gx _ls_output (eza --color=always --grid)
end

# Print ls after cd
function cd
    if command -v z &>/dev/null
        z $argv
    else
        builtin cd $argv
    end
end

function mkcd
    mkdir -p "$argv[1]" && cd "$argv[1]"
end

function cp-mkdir
    mkdir -p (dirname "$argv[2]") && cp "$argv[1]" "$argv[2]"
end

function lfcd
    cd (lf --print-last-dir $argv)
end

# Get local IP address, given interface name
function ipv4-dev
    test -z "$argv[1]"; and echo "Usage: ipv4-dev <interface>"; and return 1
    ip addr show "$argv[1]" | grep 'inet ' | grep -v '127.0.0.1' | cut -d' ' -f6 | cut -d/ -f1
end

function ipv6-dev
    test -z "$argv[1]"; and echo "Usage: ipv6-dev <interface>"; and return 1
    ip addr show "$argv[1]" | grep 'inet6 ' | cut -d' ' -f6 | sed -n '1p' | cut -d/ -f1
end

# Sudo with custom aliases and functions
# function mysudo
#     if test (count $argv) -eq 0
#         echo "Usage: mysudo <command>"
#         return 1
#     end
# 
#     set -l functs "$HOME/.functions.fish"
#     set -l aliases "$HOME/.aliases.fish"
# 
#     if not test -f "$functs"; or not test -f "$aliases"
#         echo "Error: one or multiple shell files not found"
#         return 1
#     end
# 
#     set -l command (string join ' ' $argv)
# 
#     sudo fish -c "
#       source '$functs';
#       source '$aliases';
#       $command
#     "
# end

function date-backup
    set -l d (date +"%Y-%m-%d_%H-%M-%S")

    if not test -e "$argv[1]"
        echo "Error: File '$argv[1]' not found."
        return 1
    end

    set -l fdir (dirname "$argv[1]")
    set -l fname (basename "$argv[1]")

    mv "$argv[1]" "$fdir/$fname.$d.bak"
end

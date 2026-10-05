# Shell Functions

# Print ls after cd on interactive shells
function ls_on_cd --on-variable PWD
    status is-interactive; and ls
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

function cats
    bat --no-pager --style=grid,header-filename $argv
end

function quick-launch
    set -l app $argv[1]
    if not type -q $app
        echo "Error: '$app' not found in PATH"
        return 1
    end

    # setsid completely detaches the process into a brand new session group
    # </dev/null breaks the standard input connection
    if test (count $argv) -gt 1
        setsid $argv[1] $argv[2..-1] </dev/null &>/dev/null &
    else
        setsid $argv[1] </dev/null &>/dev/null &
    end

    # close the terminal instance running this shell
    kill $fish_pid
end
complete -c quick-launch -f
complete -c quick-launch -a "(__fish_complete_command)"

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

function notify-me
    set -l title "notify-me"
    set -l message "done"
    switch (count $argv)
        case 1
            set message $argv[1]
        case 2
            set title $argv[1]
            set message $argv[2]
    end
    notify-send "$title" "$message"; and paplay /usr/share/sounds/freedesktop/stereo/bell.oga
end

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

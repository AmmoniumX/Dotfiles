# Bash Functions

if [[ ! -f ~/.bash-preexec.sh ]]; then
    echo ".bash-preexec.sh not found, installing"
    curl https://raw.githubusercontent.com/rcaloras/bash-preexec/master/bash-preexec.sh -o ~/.bash-preexec.sh
fi
source ~/.bash-preexec.sh

# bash-preexec hook
preexec() {
  # Log time, working directory, and command to a custom file
  local timestamp=$(date "+%Y-%m-%d %H:%M:%S")
  local working_dir=$(pwd)
  local command="$1"
  echo "$timestamp $working_dir $command" >> ~/.bash_full_history

  # Reset ls-after-cd after ran once
  unset _ls_output
}

# Print ls after cd and clear
function cd() {
  if builtin cd "$@"; then
    # Capture ls output
    export _ls_output=$(eza --color=always --grid) # Works since eza v0.23.0
  fi
}

function clear() {
  if $(which clear); then
    # Capture ls output
    export _ls_output=$(eza --color=always --grid) # Works since eza v0.23.0
  fi
}

function mkcd() { mkdir -p "$1" && cd "$1"; }
function cp-mkdir() { mkdir -p "$(dirname "$2")" && cp "$1" "$2"; }
function lfcd () {
    tmp="$(mktemp)"
    lf -last-dir-path="$tmp" "$@"
    if [ -f "$tmp" ]; then
        dir="$(cat "$tmp")"
        rm -f "$tmp"
        if [ -d "$dir" ]; then
            cd "$dir"
        fi
    fi
}

function gcam() {
    git commit -am "$@"
}

# Get local IP address, given interface name
function ipv4-dev() {
    [[ -z "$1" ]] && { echo "Usage: ipv4-dev <interface>"; return 1; }
    ip addr show "$1" | grep 'inet ' | grep -v '127.0.0.1' | cut -d' ' -f6 | cut -d/ -f1;
}

function ipv6-dev() {
    [[ -z "$1" ]] && { echo "Usage: ipv6-dev <interface>"; return 1; }
    ip addr show "$1" | grep 'inet6 ' | cut -d' ' -f6 | sed -n '1p' | cut -d/ -f1;
}

# Sudo with custom aliases and functions
function mysudo() {
  # Check if a command is provided
  [[ -z "$1" ]] && { echo "Usage: mysudo <command>"; return 1; }

  # Paths to your bash files
  local functs="$HOME/.bash-functions.sh"
  local aliases="$HOME/.bash-aliases.sh"

  # Check if files exist before sourcing
  [[ ! -f "$functs" || ! -f "$aliases" ]] && { echo "Error: one or multiple bash files not found"; return 1; }

  # Build the command
  local command="$*"

  # Use sudo to execute the command in a new bash shell with sourced files
  sudo bash -c "
    shopt -s expand_aliases;
    source '$functs';
    source '$aliases';
    $command
  "
}


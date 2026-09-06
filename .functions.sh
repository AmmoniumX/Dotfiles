# Shell Functions

# Print ls after cd
function cd() {
  # Check if the 'z' command is available/exists
  if command -v z &> /dev/null; then
    z "$@" && ls
  else
    builtin cd "$@" && ls
  fi
}

function mkcd() { mkdir -p "$1" && cd "$1"; }
function cp-mkdir() { mkdir -p "$(dirname "$2")" && cp "$1" "$2"; }
function lfcd () {
    cd "$(lf --print-last-dir "$@")"
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

function notify-me() {
  local title="notify-me"
  local message="done"
  if [[ "$#" -eq 1 ]]; then
    message="$1"
  elif [[ "$#" -eq 2 ]]; then
    title="$1"
    message="$2"
  fi
  notify-send "$title" "$message" && \
    paplay /usr/share/sounds/freedesktop/stereo/bell.oga
}

# Sudo with custom aliases and functions
# function mysudo() {
#   # Check if a command is provided
#   [[ -z "$1" ]] && { echo "Usage: mysudo <command>"; return 1; }
# 
#   # Paths to your shell files
#   local functs="$HOME/.functions.sh"
#   local aliases="$HOME/.aliases.sh"
# 
#   # Check if files exist before sourcing
#   [[ ! -f "$functs" || ! -f "$aliases" ]] && { echo "Error: one or multiple shell files not found"; return 1; }
# 
#   # Build the command
#   local command="$*"
# 
#   # Use sudo to execute the command in a new shell with sourced files
#   if [[ -n "$BASH_VERSION" ]]; then
#     sudo bash -c "
#       shopt -s expand_aliases;
#       source '$functs';
#       source '$aliases';
#       $command
#     "
#   elif [[ -n "$ZSH_VERSION" ]]; then
#     sudo zsh -c "
#       source '$functs';
#       source '$aliases';
#       $command
#     "
#   fi
# }

function date-backup() {
  local d=$(date +"%Y-%m-%d_%H-%M-%S")

  # Check file exists
  if [[ ! -e "$1" ]]; then
    echo "Error: File '$1' not found."
    return 1
  fi

  local fdir=$(dirname "$1")
  local fname=$(basename "$1")

  mv "$1" "${fdir}/${fname}.${d}.bak"
}

# Shell Functions

if [[ -n "$BASH_VERSION" ]]; then
  # Bash-specific setup
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

    # Reset ls-after-cd    
    unset _ls_output
  }

  # bash-precmd hook
  # precmd() {
  #   if [[ -n "$_ls_output" ]]; then
  #     echo "$_ls_output"
  #     unset _ls_output
  #   fi
  # }
  # precmd_functions+=(precmd)

elif [[ -n "$ZSH_VERSION" ]]; then
  # Zsh-specific setup
  preexec() {
    # Log time, working directory, and command to a custom file
    local timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    local working_dir=$(pwd)
    local command="$1"
    echo "$timestamp $working_dir $command" >> ~/.zsh_full_history

    # Reset ls-after-cd    
    unset _ls_output
  }

  chpwd() {
    # Capture ls output
    export _ls_output=$(eza --color=always --grid) # Works since eza v0.23.0
  }

  # precmd() {
  #   if [[ -n "$_ls_output" ]]; then
  #     print -P "%{%}"$_ls_output
  #     unset _ls_output
  #   fi
  # }
fi

# Print ls after cd
function cd() {
  # Check if the 'z' command is available/exists
  if command -v z &> /dev/null; then
    if z "$@"; then
      # Capture ls output only if z was successful (returned 0)
      export _ls_output=$(eza --color=always --grid)
    fi
  else
    if builtin cd "$@"; then
      # Capture ls output only if z was successful (returned 0)
      export _ls_output=$(eza --color=always --grid)
    fi
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

# Sudo with custom aliases and functions
function mysudo() {
  # Check if a command is provided
  [[ -z "$1" ]] && { echo "Usage: mysudo <command>"; return 1; }

  # Paths to your shell files
  local functs="$HOME/.functions.sh"
  local aliases="$HOME/.aliases.sh"

  # Check if files exist before sourcing
  [[ ! -f "$functs" || ! -f "$aliases" ]] && { echo "Error: one or multiple shell files not found"; return 1; }

  # Build the command
  local command="$*"

  # Use sudo to execute the command in a new shell with sourced files
  if [[ -n "$BASH_VERSION" ]]; then
    sudo bash -c "
      shopt -s expand_aliases;
      source '$functs';
      source '$aliases';
      $command
    "
  elif [[ -n "$ZSH_VERSION" ]]; then
    sudo zsh -c "
      source '$functs';
      source '$aliases';
      $command
    "
  fi
}


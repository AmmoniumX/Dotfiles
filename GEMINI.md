# Dotfiles Repository Structure

This document outlines the structure of this Dotfiles repository, explaining the purpose of each file and directory.

## Files

- **`.bash-aliases.sh`**: Contains custom command aliases for the Bash shell.
- **`.bash-functions.sh`**: Holds custom functions for the Bash shell.
- **`.bash-preexec.sh`**: A script for pre-execution hooks in Bash.
- **`.bashrc`**: The main configuration file for the Bash shell. It sources the other `.bash*` files.
- **`.gitignore`**: Specifies files and directories that Git should ignore.
- **`.nanorc`**: Configuration file for the `nano` text editor.
- **`install.sh`**: A script to set up the dotfiles on a new system.
- **`README.md`**: The main README file for the repository.

## Directories

- **`.backups/`**: A directory for storing backups of previous dotfile configurations.
- **`.config/`**: Contains configuration files for various applications.
  - **`kscreenlockerrc`**: Configuration for the KDE screen locker.
  - **`starship.toml`**: Configuration for the Starship cross-shell prompt.
- **`.git/`**: The Git directory, containing all the information about the repository.

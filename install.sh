#!/usr/bin/bash

for file in ./* ./.*; do
    [ -e "$file" ] || continue
    [ "$(basename "$file")" == "install.sh" ] && continue
    [ "$(basename "$file")" == ".git" ] && continue

    echo "Installing $file -> $HOME/$(basename "$file")"
    ln -s "$file" "$HOME/$(basename "$file")"
done

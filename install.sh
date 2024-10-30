#!/usr/bin/bash

for f in ./* ./.*; do
    [ -e "$f" ] || continue
    file="$(realpath "$f")"

    [ "$(basename "$file")" == "install.sh" ] && continue
    [ "$(basename "$file")" == ".git" ] && continue

    echo "Installing $file -> $HOME/$(basename "$file")"
    ln -s "$file" "$HOME/$(basename "$file")"
done

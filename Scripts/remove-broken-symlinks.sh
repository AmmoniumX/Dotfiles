#!/bin/bash
find ~/.config -type l ! -exec test -e {} \; -exec rm -v {} \;

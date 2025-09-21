#!/bin/sh
echo -ne '\033c\033]0;Godot-Wild-Jam-85\a'
base_path="$(dirname "$(realpath "$0")")"
"$base_path/Cold_Expansion.x86_64" "$@"

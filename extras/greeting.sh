#!/bin/bash
# OmarchyThings terminal greeting. Sourced from ~/.bashrc by extras/install.sh.
# Shows Eleven (Braille art in eleven.txt) and "The Gate is Open." when a new
# interactive terminal opens, but only while the OmarchyThings theme is the
# active Omarchy theme. Reads two small files, starts no programs.
[[ $- == *i* ]] || return 0 2>/dev/null || exit 0
[[ -r "$HOME/.local/state/omarchy/current/theme.name" ]] || return 0
read -r _st_theme < "$HOME/.local/state/omarchy/current/theme.name"
if [[ $_st_theme != omarchy-things ]]; then unset _st_theme; return 0; fi
unset _st_theme
_st_art="${BASH_SOURCE[0]%/*}/eleven.txt"
if [[ -r $_st_art ]]; then
  mapfile -t _st_lines < "$_st_art"
  printf '%s\n' "${_st_lines[@]}"
  printf '\e[1;31m%s\e[0m\n\n' "               The Gate is Open."
fi
unset _st_art _st_lines

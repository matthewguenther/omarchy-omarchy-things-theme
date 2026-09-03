#!/bin/bash
# Installs the OmarchyThings extras that an Omarchy theme cannot ship on its own:
#   - cliamp music player theme      -> ~/.config/cliamp/themes/omarchy-things.toml
#   - Demogorgon About-screen logo   -> ~/.config/omarchy-things/about.txt (swapped in by the hook)
#   - terminal greeting              -> ~/.config/omarchy-things/greeting.sh + one block in ~/.bashrc
#   - theme-set hook                 -> ~/.config/omarchy/hooks/theme-set.d/
# Safe to run more than once. Run with --uninstall to remove everything it added.
set -euo pipefail

HERE=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
ROOT=$(cd "$HERE/.." && pwd)
ST_DIR="$HOME/.config/omarchy-things"
BASHRC="$HOME/.bashrc"
MARK_START="# >>> omarchy-things greeting >>>"
MARK_END="# <<< omarchy-things greeting <<<"
HOOK="$HOME/.config/omarchy/hooks/theme-set.d/theme-set.sh"
FF_CONF="$HOME/.config/fastfetch/config.jsonc"

# An earlier version linked a custom fastfetch config, which stops Omarchy from
# sizing the About window. Undo that if it is still there.
remove_old_fastfetch_link() {
  if [[ -L $FF_CONF && $(readlink "$FF_CONF") == "$ST_DIR/fastfetch.jsonc" ]]; then
    rm -f "$FF_CONF"
    [[ -f $FF_CONF.before-omarchy-things ]] && mv "$FF_CONF.before-omarchy-things" "$FF_CONF"
  fi
  rm -f "$ST_DIR/fastfetch.jsonc" "$ST_DIR/demogorgon.txt"
}

remove_bashrc_block() {
  [[ -f $BASHRC ]] && grep -qF "$MARK_START" "$BASHRC" || return 0
  cp "$BASHRC" "$BASHRC.bak.omarchy-things"
  sed -i "/^$MARK_START\$/,/^$MARK_END\$/d" "$BASHRC"
}

if [[ ${1:-} == --uninstall ]]; then
  remove_bashrc_block
  rm -f "$HOME/.config/cliamp/themes/omarchy-things.toml" "$HOOK"
  remove_old_fastfetch_link
  # give Omarchy its own About logo back
  bash "$ROOT/hooks/theme-set.sh" "not-ours"
  rm -rf "$ST_DIR"
  echo "OmarchyThings extras removed. Open a new terminal to see the change."
  exit 0
fi

mkdir -p "$ST_DIR" "$HOME/.config/cliamp/themes"
cp "$HERE/cliamp/omarchy-things.toml" "$HOME/.config/cliamp/themes/omarchy-things.toml"
remove_old_fastfetch_link
# The About logo is plain text; color each line red with an escape code so it
# stays red under Omarchy's default fastfetch config.
sed 's/^/\x1b[31m/' "$HERE/fastfetch/demogorgon.txt" > "$ST_DIR/about.txt"
cp "$HERE/greeting.sh" "$ST_DIR/greeting.sh"
cp "$HERE/eleven.txt" "$ST_DIR/eleven.txt"

remove_bashrc_block
cat >> "$BASHRC" <<BLOCK
$MARK_START
[[ -r ~/.config/omarchy-things/greeting.sh ]] && source ~/.config/omarchy-things/greeting.sh
$MARK_END
BLOCK

omarchy hook install theme-set "$ROOT/hooks/theme-set.sh" >/dev/null
# Apply the hook to whatever theme is active right now.
"$HOOK" "$(cat "$HOME/.local/state/omarchy/current/theme.name" 2>/dev/null || true)"

cat <<MSG
Installed:
  - cliamp theme        ~/.config/cliamp/themes/omarchy-things.toml
  - About-screen logo   $ST_DIR/about.txt
  - greeting            one marked block at the end of ~/.bashrc
  - theme hook          $HOOK
Open a new terminal to see the greeting. Run with --uninstall to undo.
MSG

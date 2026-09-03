#!/bin/bash
# Omarchy theme-set hook for the OmarchyThings theme.
# Installed by extras/install.sh with: omarchy hook install theme-set hooks/theme-set.sh
# Runs after every theme change with the new theme slug in $1.
#
# When our theme is selected: switch cliamp to its OmarchyThings theme and put
# the Demogorgon in Omarchy's About logo file (~/.config/omarchy/branding/about.txt),
# which Omarchy measures so the About window is sized to fit it.
# When any other theme is selected: put both back the way they were.

THEME="${1:-}"
OURS=0
[[ $THEME == omarchy-things ]] && OURS=1

ST_DIR="$HOME/.config/omarchy-things"
CLIAMP_CONF="$HOME/.config/cliamp/config.toml"
CLIAMP_SAVED="$ST_DIR/cliamp-theme-before"
ABOUT="$HOME/.config/omarchy/branding/about.txt"
ABOUT_OURS="$ST_DIR/about.txt"
ABOUT_SAVED="$ABOUT.before-omarchy-things"

# --- cliamp -----------------------------------------------------------------
if [[ -f $CLIAMP_CONF ]]; then
  current=$(sed -n 's/^theme = "\(.*\)"$/\1/p' "$CLIAMP_CONF" | head -1)
  if (( OURS )); then
    if [[ $current != omarchy-things ]]; then
      mkdir -p "$ST_DIR"
      printf '%s\n' "$current" > "$CLIAMP_SAVED"
      if grep -q '^theme = ' "$CLIAMP_CONF"; then
        sed -i 's/^theme = .*/theme = "omarchy-things"/' "$CLIAMP_CONF"
      else
        printf '\ntheme = "omarchy-things"\n' >> "$CLIAMP_CONF"
      fi
    fi
  elif [[ $current == omarchy-things ]]; then
    previous=""; [[ -f $CLIAMP_SAVED ]] && read -r previous < "$CLIAMP_SAVED"
    sed -i "s/^theme = .*/theme = \"$previous\"/" "$CLIAMP_CONF"
    rm -f "$CLIAMP_SAVED"
  fi
fi

# --- About screen logo ---------------------------------------------------------
is_ours() { [[ -f $ABOUT && -f $ABOUT_OURS ]] && cmp -s "$ABOUT" "$ABOUT_OURS"; }
if (( OURS )); then
  if [[ -f $ABOUT_OURS ]] && ! is_ours; then
    mkdir -p "$(dirname "$ABOUT")"
    [[ -f $ABOUT ]] && cp "$ABOUT" "$ABOUT_SAVED"
    cp "$ABOUT_OURS" "$ABOUT"
  fi
elif is_ours; then
  if [[ -f $ABOUT_SAVED ]]; then mv "$ABOUT_SAVED" "$ABOUT"; else rm -f "$ABOUT"; fi
fi

exit 0

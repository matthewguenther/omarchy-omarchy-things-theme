# Extras

Things Omarchy cannot install from a theme repo, so `install.sh` puts them in
place (and `install.sh --uninstall` takes them out again):

- `cliamp/omarchy-things.toml` — music player theme
- `fastfetch/demogorgon.txt` (Braille art from emojicombos.com) — Demogorgon for the About screen. The installer colors it red and the hook drops it into `~/.config/omarchy/branding/about.txt`, so Omarchy sizes the About window to fit it.
- `greeting.sh` + `eleven.txt` — Eleven printed when a terminal opens, only while
  the theme is active
- `../hooks/theme-set.sh` — switches cliamp and the About logo with the theme
- `tools/make-unlock.sh` — regenerates the boot-screen preview

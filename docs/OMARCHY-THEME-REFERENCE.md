# Omarchy theme reference (verified on Omarchy 4.0.2, 2026-09-03)

Everything below was checked against the scripts in `/usr/share/omarchy/bin`
and the templates in `/usr/share/omarchy/default/themed`. Trust this over
memory. Re-verify only if `omarchy version` has changed.

## Where themes live

- Stock themes: `/usr/share/omarchy/themes/<slug>/` (read-only, good examples:
  `tokyo-night`, `retro-82`, `hackerman`).
- User themes: `~/.config/omarchy/themes/<slug>/`.
- `omarchy theme set <slug>` copies the stock theme (if one exists) then
  overlays the user theme, runs the templates, and swaps the result into
  `~/.local/state/omarchy/current/theme/`.
- Extra wallpapers per theme: `~/.config/omarchy/backgrounds/<slug>/`.

## Trust levels (important)

`omarchy-theme-set` checks whether the user theme dir has a `.git` directory
and is not a symlink. If so it is "from a repo" and these files are DROPPED:
every `*.lua` (`hyprland.lua`, `gum_env.lua`, `neovim.lua`), `alacritty.toml`,
`foot.ini`, `ghostty.conf`, `kitty.conf`, `vscode.json`. They are regenerated
from `colors.toml`.

Kept from a repo theme: `colors.toml`, `icons.theme`, `keyboard.rgb`,
`shell.toml`, `shell.<section>.toml`, `btop.theme`, `chromium.theme`,
`helix.toml`, `backgrounds/`, `unlock.png`, `preview*.png`, any other files.

A **symlink** to a working copy counts as the user's own theme and nothing is
dropped. That is our dev setup. Final testing must clone the repo for real to
see what a stranger gets (see T13).

## colors.toml

```toml
mode = "dark"            # or "light"

accent = "#..."          # borders, cursor, selected text, Claude Code prompt
selection = "#..."       # selection background
muted = "#..."           # subtle text

background = "#..."
dark_background = "#..."
darker_background = "#..."
lighter_background = "#..."

foreground = "#..."
dark_foreground = "#..."
light_foreground = "#..."
bright_foreground = "#..."

red, yellow, orange, green, cyan, blue, magenta, brown = "#..."
bright_red, bright_yellow, bright_green, bright_cyan, bright_blue, bright_magenta = "#..."

# Optional extras used by templates:
hyprland_active_border   = "#e53935 #b47ee5 45deg"   # one color or a gradient
hyprland_inactive_border = "rgba(595959aa)"
```

Facts learned by testing `omarchy-theme-color --file colors.toml --all`:

- Any key you add passes through to templates as `{{ key }}`. Templates also
  get `{{ key_strip }}` (no `#`), `{{ key_rgb }}` (`r,g,b`), and
  `{{ mix a b 30% }}`.
- Missing keys are derived, sometimes badly. With only the 6 base colors
  set, Omarchy chose `muted = foreground`, `selection = background`,
  `dark_foreground = foreground`, `lighter_background = background`. Define
  all of them explicitly.
- Derived names `color0`–`color15`, `bg`, `fg`, `purple`, `cursor`,
  `selection_background`, `selection_foreground`, `theme_type` are computed
  automatically.

## What gets generated from colors.toml

Templates in `/usr/share/omarchy/default/themed/*.tpl` produce:
`alacritty.toml`, `foot.ini`, `ghostty.conf`, `kitty.conf`, `btop.theme`,
`chromium.theme`, `claude.json` (Claude Code), `gum_env.lua`, `helix.toml`,
`hyprland.lua`, `hyprland-preview-share-picker.css`, `keyboard.rgb`,
`neovim.lua` (uses `bjarneo/aether.nvim` with our palette), `obsidian.css`,
`pi.json`, `shell.toml`, `vscode-theme.json`.

A file with the same name shipped in the theme wins over the template
(except the dropped ones above when installed from git).

`shell.toml` sections: `[bar] [hyprland] [controls] [spacing] [font] [popups]
[tooltip] [notifications] [launcher] [menu] [polkit] [lock] [image-picker]`.
You can override a single section with a file named `shell.<section>.toml`
(example: tokyo-night ships `shell.lock.toml`).

After applying, Omarchy also restarts terminals, btop, helix and pushes the
theme to Claude Code (`~/.claude/themes/omarchy.json`), VS Code, browsers,
Obsidian, tmux, GNOME apps, and the keyboard.

## Image sizes (from tokyo-night)

| File                 | Size       | Notes                               |
|----------------------|------------|-------------------------------------|
| `unlock.png`         | 1108x523   | transparent PNG, centered logo      |
| `preview.png`        | 1800x1012  | shown in `omarchy theme` picker     |
| `preview-unlock.png` | 1920x1080  | lock screen preview                 |
| backgrounds          | up to 5120x2880 | jpg or png, sorted by filename |

`icons.theme` contains one line, e.g. `Yaru-magenta`. `keyboard.rgb`
contains one hex value with no `#`, e.g. `ff00ff`.

## Fonts

Themes cannot set the font. `omarchy font list` / `omarchy font set <name>`.
Installed monospace choices: Adwaita Mono, iA Writer Mono S, JetBrainsMono
Nerd Font, Liberation Mono, Nimbus Mono PS.

## Hooks

`~/.config/omarchy/hooks/theme-set.d/*.sh` run after every theme change with
the slug in `$1`. Install with `omarchy hook install theme-set <script>`.
Other hooks: `font-set`, `post-boot`, `post-update`, `battery-low`.

## fastfetch (the "About" screen)

Default config: `/etc/fastfetch/config.jsonc`; user override:
`~/.config/fastfetch/config.jsonc`. The logo is a text file
(`~/.config/omarchy/branding/about.txt` by default) with
`"logo": {"type": "file", "source": "...", "color": {"1": "green"}}`.
Inside the text file, `$1`, `$2` ... switch to the colors mapped in
`logo.color` (fastfetch convention). The Omarchy menu launches
`fastfetch` in a floating terminal for About.

Terminals do NOT run fastfetch on open by default. `~/.bashrc` sources
`/usr/share/omarchy/default/bash/rc` then has a "add your own" section; a
greeting line goes there (the install script appends it).

## cliamp themes

Files in `~/.config/cliamp/themes/<name>.toml`, selected with
`theme = "<name>"` in `~/.config/cliamp/config.toml` or
`cliamp --start-theme <name>`, or `t` inside the player.

```toml
bg = "#0b0a10"        # optional
accent = "#e53935"    # titles, seek bar, selected items
bright_fg = "#f4eee2" # primary text
fg = "#8d8599"        # muted text, help bar
green = "#57c785"     # playing / spectrum low
yellow = "#f2c14e"    # warnings / spectrum mid
red = "#e5393a"       # errors / spectrum high
```

Built-in cliamp themes exist for most stock Omarchy themes (tokyo-night,
catppuccin, hackerman...), so a matching one for ours is expected.

## Claude Code theme

Generated from `claude.json.tpl`: accent = prompt border and Claude label,
cyan = suggestions/plan mode, blue = permission prompts, yellow = warnings and
auto-accept, green/red = diffs. Nothing to write; just check readability.

## Publishing (later)

Repo naming convention `omarchy-<slug>-theme`; `omarchy theme install <url>`
strips `omarchy-` and `-theme` to get the slug. To be listed on
omarchy.org/themes: PR to `github.com/omacom/omarchy-site` with a 1200x675
webp under ~100KB in `assets/themes/` (make it with
`magick preview.png -strip -resize '1200>' -quality 80 omarchy-things.webp`)
plus a `<figure>` block in `themes/index.html`, alphabetical.

## Useful commands

```bash
omarchy theme current
omarchy theme set omarchy-things
omarchy theme bg next
omarchy-theme-color --file colors.toml --all      # see every resolved key
ls ~/.local/state/omarchy/current/theme/          # generated output
omarchy capture screenshot
omarchy restart terminal
```

## Screenshots and window juggling

- The terminal on this machine is **foot** (alacritty is not installed).
- `hyprctl dispatch` on Omarchy 4 takes Lua, not the old keywords:
  `hyprctl dispatch 'hl.dsp.focus({ workspace = "5" })'`,
  `hyprctl dispatch 'hl.dsp.window.close()'` (closes the focused window).
  New windows open on the focused monitor's active workspace, so focus a
  spare workspace first, launch with `setsid foot --title x cmd &`, wait a
  few seconds, then `grim -o DP-3 out.png` (DP-3 is the 4K main monitor,
  DP-2 the 1440p one). `grim -g "X,Y WxH"` captures one window; get the
  geometry from `hyprctl clients -j`.
- `omarchy-notification-dismiss "<title>"` clears a stuck notification.
- Persistent crash notifications come from Omarchy's crash watcher; an
  ImageMagick "Illegal instruction" happened once and was not reproducible.

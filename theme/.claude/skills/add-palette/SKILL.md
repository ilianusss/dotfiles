---
name: add-palette
description: How to add (or change, or remove) a color palette / theme in ~/.theme, tool by tool — base16 slots (importing a scheme or writing one with the skeleton), the terminal's ANSI colors (Ghostty), the Neovim colorscheme, the Claude Code skin (derived, claude_skin, claude_<slot>), light variants, and how to check each. Use when asked to add, port, create, tweak or delete a color scheme / theme / palette, or to fix how one looks in a given tool.
---

# Adding a palette

A palette is one file, `colors/<name>/palette` (format: the table in `AGENTS.md`). `<name>` is
kebab-case and says the variant: `tokyonight-night`, `rose-pine-dawn`.

What each tool takes from it — the steps below follow this order:

| Tool | Takes | Step |
|---|---|---|
| everything | `name`, `variant`, `base00`..`base0F` (required) | 1–2 |
| Ghostty, zsh prompt, ANSI tools (fzf, bat, delta, lazygit...) | `color0..15`, `background`, `foreground`, `cursor*`, `selection_*` (default: from base16) | 3 |
| Neovim | `nvim_colorscheme`, else mini.base16 from base16 | 4 |
| Claude Code (skin plugin, `.theme` mode) | `claude_skin`, `claude_<slot>`, else derived from base16 | 5 |
| SketchyBar, JankyBorders (macOS) | base16 only (`base00 02 04 05 08 0D`, roles in `AGENTS.md`): nothing to add | 6 |

## 1. Import it if a base16 scheme exists (fastest)

Look for it in https://github.com/tinted-theming/schemes (`base16/` or `base24/`), then:

```sh
theme import https://raw.githubusercontent.com/tinted-theming/schemes/spec-0.11/base16/<scheme>.yaml <name>
```

This writes `name`, `variant` and `base00..base0F`. Then go to step 3 (terminal colors).

## 2. Otherwise write it from the skeleton

```sh
mkdir colors/<name> && cp .claude/skills/add-palette/palette.skeleton colors/<name>/palette
```

Fill it from the theme's **own** source, never from memory: its Neovim plugin's palette file
(`~/.local/share/nvim/lazy/<plugin>/lua/...`), its official terminal ports (`extras/ghostty`,
`extras/kitty`, iTerm2-Color-Schemes) or the theme's README. Put the source URL in the header.

Mapping colors to base16 slots:

| Slot | Take |
|---|---|
| base00 | main editor/terminal background |
| base01 | slightly lighter: statusline, cursorline, floats |
| base02 | selection / visual background |
| base03 | comments, invisibles |
| base04 | dim foreground: line numbers, statusline text |
| base05 | main foreground |
| base06 | lighter foreground (rare) |
| base07 | brightest foreground |
| base08 | red: variables, errors, deleted |
| base09 | orange: numbers, constants |
| base0A | yellow: types, search |
| base0B | green: strings, added |
| base0C | cyan: support, regex, escapes |
| base0D | blue: functions |
| base0E | magenta/purple: keywords |
| base0F | brown/dark red: deprecated, embedded tags |

For a light palette: `variant=light`, base00 is the lightest color and base07 the darkest.

## 3. Terminal colors (optional but usually wanted)

Without `colorN` keys the ANSI colors are derived from base16, which is fine for most themes.
If the theme ships a terminal port, copy its 16 colors as `color0..color15`, plus
`background`, `foreground`, `cursor`, `selection_bg`, `selection_fg` from it, so the terminal
looks exactly like the original. Ghostty already has hundreds:
`ls "/Applications/Ghostty.app/Contents/Resources/ghostty/themes"` (Linux: `/usr/share/ghostty/themes`).

## 4. Neovim (optional)

By default mini.base16 generates the colorscheme from base00..base0F. If a dedicated Neovim
plugin exists and looks better, set `nvim_colorscheme=<colorscheme name>`: the plugin must be
installed in `~/.config/nvim/lua/plugins/ui/colorscheme.lua` with `lazy = false` (follow that
repo's `add-plugin` skill), else Neovim warns and falls back.

## 5. Claude Code skin (optional)

The skin plugin turns every palette into a skin by itself (no target). By default from base16:

| Slot | base16 | Paints |
|---|---|---|
| `fg` / `muted` | 05 / 04 | body text / commands, paths, timings |
| `surface` / `zebra` | 01 / mix of 00 and 01 | table header band / every other row |
| `user` | 0D | the accent: rail, prompt marker, spinner |
| `ok` / `err` / `warn` | 0B / 08 / 09 | finished / failed / interrupted call |
| `read` / `write` / `run` | 0D / 09 / 0B | Read / Edit, Write / Bash |
| `search` / `web` / `mcp` / `other` | 0E / 0C / 0A / 04 | Grep, Glob / WebFetch / MCP tools / the rest |

When the theme has a hand-made skin in the plugin (`noir tokyo-night dracula nord gruvbox catppuccin
rose-pine everforest one-dark solarized github kanagawa ayu night-owl homebrew mono`), prefer it:
`claude_skin=<name>` takes its colors **and** its spinner/footer words. Then fix single slots with
`claude_<slot>="#rrggbb"` (works on top of either). Typical fixes: `claude_user` to the theme's real
accent (the derived one is blue), `claude_muted` when base04 is too dim on base00.

The palette is drawn as-is whatever Claude Code's light/dark setting, so a light palette needs no
extra keys.

## Light variants and themes with dark + light

Each variant is its own palette: `<theme>-dark`, `<theme>-light` (only add the ones wanted).

- `variant=light`, and the base16 scale is reversed: base00 = lightest background, base05 = dark
  text, base07 = darkest. ANSI `color0` stays the darkest "black" and `color15` the lightest.
- A Neovim colorscheme that switches on `background` (like `homebrew`) works for both: point
  both palettes at it with the same `nvim_colorscheme`; `colors/theme.lua` sets `background`
  from `variant` before loading it.
- Check readability on the light background: comments (base03), selection (base02), and the
  yellow/cyan ANSI colors, which are often too pale on light themes.

### Recipe: bring back Homebrew Light

Only `homebrew-dark` is kept. Its light twin needs no download: every value is in
`~/.config/nvim/themes/colors/homebrew.lua`, under `palettes.light` and `ansi.light`.

1. `cp -r colors/homebrew-dark colors/homebrew-light`, then in the copy: header + `name="Homebrew Light"`,
   `variant=light`, keep `nvim_colorscheme=homebrew`.
2. base16 from `palettes.light`, same roles as the dark file: base00 `bg`, base01 `bg1`,
   base02 `sel`, base03 `comment`, base04 `muted`, base05 `fg`, base06/07 `fg_hi`, base08 `red`,
   base09 `copper`, base0A `honey`, base0B `hop`, base0C `teal`, base0D `ice`, base0E `amber`,
   base0F `wheat`.
3. Terminal: `color0..15` = `ansi.light` in order; `background` = `bg`, `foreground` = `fg`,
   `cursor` = `amber`, `cursor_text` = `bg`, `selection_bg` = `sel`, `selection_fg` = `fg_hi`.
4. Step 6 below.

## 6. Check

```sh
theme preview colors <name>          # all keys present? swatches look right?
theme colors <name>                  # applies to Ghostty, open Neovims and Claude Code sessions
nvim --headless "+lua print(vim.g.colors_name)" +qa
```

Look at: the prompt (ANSI green/blue/magenta), `ls --color`, a git diff, comments in Neovim
(base03 must stay readable on base00), a visual selection. On macOS: the bar (base05 and base04
readable on base00, base00 readable on base0D for the focused workspace) and the border of the
focused window (base0D). In Claude Code: `/skin list` lists the
new palette (missing = a base16 key is missing or a hex is malformed), `/skin gallery` shows every
element in its colors.

## Changing / removing

- Edit the palette, then `theme apply` (switching again also works).
- Remove: `rm -r colors/<name>`. If it was selected, pick another with `theme colors` first.
- Never edit `generated/`: it is rewritten on every apply.

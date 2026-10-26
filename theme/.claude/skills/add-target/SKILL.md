---
name: add-target
description: How to make another tool follow ~/.theme (colors and/or font): deciding whether it needs anything at all (ANSI colors), writing targets/<tool>.zsh with render() and reload() from the skeleton, pointing the tool's config at generated/<tool>, live reload, and checking it. Use when asked to theme, sync or hook up a new app (tmux, kitty, fzf, bat, lazygit, yazi, btop...) with the theme command. (Done: Claude Code, SketchyBar, JankyBorders.)
---

# Adding a target (a tool that follows the theme)

Read `AGENTS.md` first ("How each tool follows", "Adding a target").

## 1. Does it need a target at all?

Prefer **no target**. A tool that draws with the 16 ANSI colors follows Ghostty automatically:

| Tool | Configure once |
|---|---|
| zsh prompt | `%F{green}` style names, never hex |
| fzf | default colors (no `--color` with hex), or `--color=16` |
| bat | `--theme=ansi` (or `BAT_THEME=ansi`) |
| delta | `syntax-theme = ansi` |
| lazygit, eza, ls, git | default colors |

Only write a target when the tool needs hex colors or a font, or draws outside the terminal.

### 1b. Or let the tool read ~/.theme itself

A program you control that runs for a long time (an editor config, a plugin) can read the palette
directly and follow `generated/stamp` (rewritten by every `theme apply`): no target, no generated
file. That is how Neovim (`~/.config/nvim/themes/`) and the Claude Code skin plugin
(`SKIN_THEME_HOME`, see its `docs/theme-mode.md`) work. Then the palette format and the stamp are a
contract with that repo: keep `key="value"` lines plain, and list any new keys it reads in the
palette table of `AGENTS.md`.

## 2. Find how the tool can include a file and reload

From the tool's docs (check them, don't guess):

- **Include**: a directive that reads another file (`config-file =`, `include`, `source-file`,
  `import`). If there is none, render the whole config file the tool reads into `generated/` and
  symlink the tool's config path to it, keeping the hand-written part in a template next to the
  target.
- **Reload**, best first: a signal or IPC command; the tool watching its own config (nothing to
  do); only on restart (say so in the target's header comment).

Examples to verify against current docs: tmux `tmux source-file <conf>` (if a server runs),
kitty SIGUSR1, Alacritty and WezTerm re-read their config on change.

## 3. Write `targets/<tool>.zsh` from the skeleton

```sh
cp .claude/skills/add-target/target.skeleton targets/<tool>.zsh
```

- Replace every `TOOL` placeholder. `render()` writes only `$GEN/<tool>` (or `$GEN/<tool>.<ext>`). Every palette key is set
  (defaults filled), plus `font_family`/`font_size`/`font_features` when a font is selected,
  `$THEME_COLORS`, `$THEME_FONT`.
- `reload()` must not fail when the tool isn't installed or running: guard with
  `(( $+commands[<tool>] )) || return 0` and end with `return 0`.
- Find processes with `ps -axo pid=,comm=` + awk, not `pgrep`/`pkill`: on this Mac they don't
  see app processes (Ghostty).
- Hex colors are `#rrggbb`; strip the `#` with `${base08#\#}` for tools that want `rrggbb`.

## 4. Point the tool at the generated file

Add the include to the tool's own config with a comment pointing here, e.g.
`# Colors from ~/.theme (the theme command)`. Use the "optional include" form when the tool has
one, so the config still loads on a machine without `~/.theme`.

If that config isn't in `~/.dotfiles` yet, move it to `~/.dotfiles/<tool>/` and add it to `LINKS`
in `~/.dotfiles/bin/dotfiles`, then run `dotfiles install`: every machine gets the include. A tool
of one OS only goes in `LINKS+=(...)` of `~/.dotfiles/platforms/<os>.zsh` instead (SketchyBar,
JankyBorders: `platforms/darwin.zsh`). Its target still runs everywhere, so `render()` writes its
file on every OS and `reload()` returns 0 where the tool isn't installed.

A tool that draws text outside the terminal takes `nerd_font_family` (always set when a font is
selected), not `font_family`: see `targets/sketchybar.zsh`.

## 5. Check and document

```sh
zsh -n targets/<tool>.zsh
theme apply && cat generated/<tool>
theme colors <another>       # the tool changes live (or on restart, as documented)
```

Then add a row to the "How each tool follows" table in `AGENTS.md`.

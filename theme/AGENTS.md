# ~/.theme

One place for the colors and the font of every tool on this machine (macOS and Linux). Pick them
with the `theme` command; every tool (Ghostty, the zsh prompt, Neovim, Claude Code, and on macOS
SketchyBar and JankyBorders) follows, live.
It lives in `~/.dotfiles/theme`; `~/.theme` is a link to it, made by `dotfiles install`.

## Commands (`bin/theme`, on PATH via ~/.zshrc, with zsh completion)

```sh
theme                            # pick a palette: fzf, live preview everywhere, Enter keep, Esc revert
theme colors [<name>]            # pick / set the palette
theme font [<name>]              # pick / set the font
theme apply                      # re-render every target (after editing a palette or a target)
theme import <url|file> <name>   # palette from a tinted-theming base16/base24 YAML scheme
theme list [colors|font]         # * = selected
theme current
```

## Layout

```
bin/theme                  the command
colors/<name>/palette      a color palette (format below). Skill: add-palette
fonts/<name>/font          a font (format below). Skill: add-font
targets/<tool>.zsh         how one tool is themed: render() + reload(). Skill: add-target
completions/_theme         zsh completion (on fpath via ~/.zshrc)
current/colors -> ../colors/<name>   the selection (symlinks, gitignored)
current/font   -> ../fonts/<name>
generated/                 files written by targets + `stamp`; NEVER edit (gitignored)
```

## Palette format: `colors/<name>/palette`

Shell `key="value"` lines, read by three parsers: zsh (`source`), Neovim
(`themes/lua/theme/palette.lua`) and the Claude Code skin plugin (`hooks/skins/theme-home.ts`).
So keep it plain: no spaces around `=`, one key per line, `# comments` on their own line or after a
value, no shell expansion.

| Key | Required | Meaning / default |
|---|---|---|
| `name` | yes | Display name (also the Claude skin's label) |
| `variant` | yes | `dark` or `light` (Neovim `background`) |
| `base00`..`base0F` | yes | [base16 styling](https://github.com/tinted-theming/home/blob/main/styling.md): 00-07 backgrounds -> foregrounds, 08 red, 09 orange, 0A yellow, 0B green, 0C cyan, 0D blue, 0E magenta, 0F brown |
| `background` `foreground` | no | base00, base05 |
| `cursor` `cursor_text` | no | foreground, background |
| `selection_bg` `selection_fg` | no | base02, foreground |
| `color0`..`color15` | no | ANSI terminal colors; default = base16 mapping (0=00 1=08 2=0B 3=0A 4=0D 5=0E 6=0C 7=05 8=03 9-14=1-6 15=07) |
| `nvim_colorscheme` | no | Neovim uses this colorscheme instead of generating one from base16 with mini.base16 |
| `claude_skin` | no | Claude Code skin: start from this built-in skin of the plugin (`kanagawa`, `gruvbox`, `homebrew`...: its colors and spinner words) instead of deriving it from base16 |
| `claude_<slot>` | no | Claude Code skin: one slot's color, `"#rrggbb"`. Slots: `user fg muted surface zebra ok err warn read write run search web mcp other`; derivation table in the add-palette skill |

`bin/theme` fills the defaults (`load_palette`), so targets can rely on every key being set.

## Font format: `fonts/<name>/font`

```sh
# <Font name> — where it comes from / how to install it
font_family="JetBrains Mono"   # exact family name: `ghostty +list-fonts`
font_size=13
font_features="-calt, -liga"   # optional, OpenType features (ligatures off here)
nerd_font_family="JetBrainsMono Nerd Font"   # optional, default font_family
```

The terminal draws most text: terminal Neovim and the shell get the font from Ghostty, which has
the font built in and adds Nerd Font icons itself. Tools that draw outside the terminal
(SketchyBar) use `nerd_font_family` instead: the Nerd Font build of the same font, installed on the
system, so the icons draw too. Without it they get `font_family`, which must then be installed and
draws no icons. Only the family follows the theme there: each tool keeps its own size.

## How each tool follows

| Tool | Reads | Live update |
|---|---|---|
| Ghostty | `generated/ghostty`, included by its config (`config-file = ?~/.theme/generated/ghostty` in `~/.dotfiles/ghostty/config.ghostty`, linked to `~/.config/ghostty/config.ghostty` on macOS and Linux) | `targets/ghostty.zsh` sends SIGUSR2 = reload config (toast disabled with `app-notifications = no-config-reload`) |
| zsh prompt | nothing: it uses ANSI color names (`%F{green}`), which are the terminal palette | with Ghostty |
| Neovim | `~/.config/nvim/themes/colors/theme.lua` reads `current/colors/palette` | watcher on `generated/` in `lua/config/colorscheme.lua` (debounced) |
| SketchyBar (macOS) | `generated/sketchybar`, sourced by `~/.dotfiles/sketchybar/sketchybarrc`. Bar `base00`, text `base05`, other workspaces `base04`, accent (icons, focused workspace) `base0E` with `base00` on it, warning (low battery) `base08`, font `nerd_font_family` | `targets/sketchybar.zsh` runs `sketchybar --reload` |
| JankyBorders (macOS) | `generated/borders`, sourced by `~/.dotfiles/borders/bordersrc`. Focused window `base0E` (the SketchyBar accent), the others `base02` | `targets/borders.zsh` reruns `borders` with the new colors, which updates the running one |
| superfile | `generated/superfile.toml`, linked as `theme.toml` into its theme folder by `LINKS`; its `config.toml` (`~/.dotfiles/superfile`) selects it with `theme = 'theme'`. Panel borders and selection `base0E`/`base02`, text `base05`, font from the terminal | none: read at start, so a running superfile keeps its colors until restarted |
| Claude Code ([skin plugin](https://github.com/ilianusss/claude-skin), `.theme` mode: `"env": {"SKIN_THEME_HOME": "~/.theme"}` in `settings.json` of `~/.claude` and `~/.claude-team`) | every `colors/*/palette` (one skin each) and `current/colors`; no target | polls `generated/stamp` (2 s). The other way too: `/skin <palette>` runs `bin/theme colors <palette>` |

## Adding a target (a new tool)

1. Prefer **nothing**: if the tool can use the 16 ANSI colors (fzf, bat `--theme=ansi`, lazygit,
   eza, delta...), configure it that way and it follows Ghostty for free.
2. Otherwise create `targets/<tool>.zsh`:
   ```zsh
   # <Tool>: what is themed, how the tool includes generated/<tool>, how it reloads.
   render() {
       { print "..." } >$GEN/<tool>      # every palette key + font_* + $THEME_COLORS/$THEME_FONT are set
   }
   reload() {
       <signal / IPC command> 2>/dev/null
       return 0                          # a tool that isn't running is not an error
   }
   ```
   Each target runs in its own subshell; one failing doesn't stop the others.
3. Point the tool's config at `~/.theme/generated/<tool>` (an include), never copy colors into it.
   The config itself lives in `~/.dotfiles/<tool>/`, linked by `LINKS` in `~/.dotfiles/bin/dotfiles`
   (or in `~/.dotfiles/platforms/<os>.zsh` for a tool of one OS only, like SketchyBar).
4. `theme apply`, check the tool, add a row to the table above.

A long-running program that can watch files may instead read `current/` (or `colors/`) itself and
watch `generated/stamp` (rewritten on every apply), like Neovim and the Claude Code skin plugin.
`generated/stamp` and the palette format are a public contract: other repos depend on them.

## Skills (`.claude/skills/`, each with a skeleton to copy)

| Skill | For |
|---|---|
| `add-palette` | a color palette, tool by tool: base16, terminal ANSI, Neovim colorscheme, Claude Code skin; light variants; Homebrew Light recipe |
| `add-font` | a font: install, exact family name, size, ligatures, its Nerd Font build for SketchyBar |
| `add-target` | make another tool follow the theme (or decide it needs nothing) |

## Conventions

- One source of truth: colors only in `colors/*/palette`, fonts only in `fonts/*/font`.
  Configs include generated files; nothing is copied by hand.
- Hex colors lowercase, always quoted: `base08="#ea6962"`.
- Folder names are kebab-case and are what `theme` shows: `gruvbox-material-dark`.
- `bin/theme` stays generic: tool-specific code goes in `targets/`.

## Verify

```sh
zsh -n bin/theme targets/*.zsh                 # syntax
theme apply && cat generated/ghostty           # renders without errors
ghostty +validate-config                       # Ghostty accepts it
theme preview colors <name>                    # swatches of one palette
nvim --headless "+lua print(vim.g.colors_name)" +qa   # "theme" or the palette's nvim_colorscheme
```

In Claude Code (skin plugin in `.theme` mode): `/skin list` shows every palette and "skins from
~/.theme/colors"; `/skin gallery` shows the selected one.

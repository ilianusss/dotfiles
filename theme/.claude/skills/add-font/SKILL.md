---
name: add-font
description: How to add (or change, or remove) a font in ~/.theme: installing it and its Nerd Font build, finding the exact family names, writing fonts/<name>/font from the skeleton (size, ligatures/OpenType features, nerd_font_family), and checking it in Ghostty and SketchyBar. Use when asked to add, install, switch, resize or tweak a terminal/editor font.
---

# Adding a font

A font is one file, `fonts/<name>/font` (format: `AGENTS.md`). `<name>` is kebab-case:
`fira-code`, `iosevka-term`, `jetbrains-mono-no-ligatures` (two presets of one family are fine).

## 1. Install it (if it isn't already)

Already available without installing: `JetBrains Mono` (built into Ghostty) and the macOS fonts
(`Menlo`, `SF Mono` only if Xcode/Terminal exposes it, `Monaco`). Otherwise:

```sh
brew search font-<name>             # Homebrew casks, e.g. font-fira-code, font-iosevka-term
brew install --cask font-<name>
```

Linux: the distro package or `~/.local/share/fonts/` + `fc-cache -f`.

The terminal needs no Nerd Font: Ghostty draws the icons itself. SketchyBar (macOS) draws outside
the terminal, so it needs the Nerd Font build of the font installed, for the icons:

```sh
brew search nerd-font | grep -i <name>   # e.g. font-jetbrains-mono-nerd-font
brew install --cask font-<name>-nerd-font
```

No Nerd Font build exists for a few fonts: pick the closest one (Menlo -> Meslo LG) or leave
`nerd_font_family` out, and the bar draws its text without icons. Add the cask to the macOS
prerequisites in `~/.dotfiles/README.md`, so every Mac gets it.

## 2. Find the exact family name

```sh
ghostty +list-fonts | grep -i <name>    # lines without indentation are family names
```

Use the family exactly as printed (`"Fira Code"`, not `FiraCode-Regular`). Fonts built into
Ghostty don't appear in that list.

The Nerd Font build has its own family, without spaces in the font's name. Ghostty lists only its
`Mono` variant, so ask fontconfig (`brew install fontconfig` if missing) or Font Book:
`fc-list : family | grep -i "nerd font"` prints `JetBrainsMono Nerd Font,JetBrainsMono NF`. Take
the plain one before the comma, not `... Nerd Font Mono` (narrow icons) or `... Nerd Font Propo`.

## 3. Write the file from the skeleton

```sh
mkdir fonts/<name> && cp .claude/skills/add-font/font.skeleton fonts/<name>/font
```

- `font_size` is in points (half points allowed: `13.5`). Same size as the current font is the
  safest start.
- `font_features` (optional): `-calt, -liga, -dlig` turns ligatures off; stylistic sets look like
  `ss01, ss02`, see the font's README or https://fontdrop.info.
- `nerd_font_family` (optional): the Nerd Font family from step 2, for SketchyBar. Default:
  `font_family`.

## 4. Check

```sh
theme preview font <name>
theme font <name>          # Ghostty reloads; zoomed windows keep their zoom (cmd+0 resets)
ghostty +validate-config
sketchybar --query front_app | grep font   # macOS: the bar uses nerd_font_family
```

If Ghostty silently shows its default font, the family name is wrong (step 2).

## Changing / removing

- Edit the file, then `theme apply`.
- Remove: `rm -r fonts/<name>`; if it was selected, pick another with `theme font` first.

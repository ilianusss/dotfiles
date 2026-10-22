---
name: add-font
description: How to add (or change, or remove) a font in ~/.theme — installing it, finding its exact family name, writing fonts/<name>/font from the skeleton (size, ligatures/OpenType features), and checking it in Ghostty. Use when asked to add, install, switch, resize or tweak a terminal/editor font.
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

Linux: the distro package or `~/.local/share/fonts/` + `fc-cache -f`. Nerd Font variants are
not needed: Ghostty draws Nerd Font icons itself.

## 2. Find the exact family name

```sh
ghostty +list-fonts | grep -i <name>    # lines without indentation are family names
```

Use the family exactly as printed (`"Fira Code"`, not `FiraCode-Regular`). Fonts built into
Ghostty don't appear in that list.

## 3. Write the file from the skeleton

```sh
mkdir fonts/<name> && cp .claude/skills/add-font/font.skeleton fonts/<name>/font
```

- `font_size` is in points (half points allowed: `13.5`). Same size as the current font is the
  safest start.
- `font_features` (optional): `-calt, -liga, -dlig` turns ligatures off; stylistic sets look like
  `ss01, ss02`, see the font's README or https://fontdrop.info.

## 4. Check

```sh
theme preview font <name>
theme font <name>          # Ghostty reloads; zoomed windows keep their zoom (cmd+0 resets)
ghostty +validate-config
```

If Ghostty silently shows its default font, the family name is wrong (step 2).

## Changing / removing

- Edit the file, then `theme apply`.
- Remove: `rm -r fonts/<name>`; if it was selected, pick another with `theme font` first.

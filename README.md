# dotfiles

My development environment (zsh, Ghostty, Neovim, Claude Code, the shared theme, and on macOS the
AeroSpace window manager with SketchyBar and JankyBorders), linked into place and kept up to date on
every machine, macOS and Linux.

## Prerequisites

- git, zsh, and an SSH key added to GitHub (for pushing)
- Neovim and Ghostty: see the [nvim README](https://github.com/ilianusss/nvim) for what it needs
- macOS: the window manager, its bar and borders, and the Nerd Fonts the bar draws its icons with:

  ```sh
  brew install --cask nikitabobko/tap/aerospace
  brew install --cask font-jetbrains-mono-nerd-font font-meslo-lg-nerd-font
  brew install FelixKratz/formulae/sketchybar FelixKratz/formulae/borders
  ```

## Getting started

1. Clone the repo and run the install:

   ```sh
   git clone git@github.com:ilianusss/dotfiles.git ~/.dotfiles
   ~/.dotfiles/bin/dotfiles install
   ```

2. Open a new shell. `dotfiles update` now runs every 15 minutes and at login.

3. macOS: open AeroSpace once and allow it in System Settings > Privacy & Security >
   Accessibility. It then starts at login, with the bar and the borders. In System Settings:
   - Control Center > Automatically hide and show the menu bar: Always (the bar takes its place)
   - Desktop & Dock > Mission Control: turn on "Group windows by application" and turn off
     "Displays have separate Spaces" (then log out)

## Commands

`dotfiles install`, `dotfiles update` and `dotfiles status` are described in
[AGENTS.md](AGENTS.md#commands-bindotfiles-on-path-via-zshzshrc).

## Project structure

```
bin/        the dotfiles command
platforms/  scheduling, notifications and the files to link, per OS
zsh/        zshrc
ghostty/    Ghostty config
theme/      colors and font of every tool
aerospace/  AeroSpace config (macOS)
sketchybar/ SketchyBar config and plugins (macOS)
borders/    JankyBorders config (macOS)
tests/      tests/run
```

## Documentation

- [AGENTS.md](AGENTS.md): the macOS window manager, how update treats a repo, adding a file, a repo
  or a platform, verifying
- [theme/AGENTS.md](theme/AGENTS.md): the theme command and its palettes

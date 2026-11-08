# dotfiles

My development environment (zsh, Ghostty, Neovim, Claude Code, the shared theme, and on macOS the
AeroSpace window manager with SketchyBar, JankyBorders and Karabiner-Elements), linked into place
and kept up to date on every machine, macOS and Linux.

## Prerequisites

- git, zsh, and an SSH key added to GitHub (for pushing)
- Neovim and Ghostty: see the [nvim README](https://github.com/ilianusss/nvim) for what it needs
- superfile, the file manager (`sf`): `brew install superfile` on macOS, see its
  [install page](https://superfile.dev/getting-started/installation/) on Linux
- macOS: the window manager, its bar and borders, Karabiner-Elements (right command as the window
  manager's key) and the Nerd Fonts the bar draws its icons with:

  ```sh
  brew install --cask nikitabobko/tap/aerospace karabiner-elements
  brew install --cask font-jetbrains-mono-nerd-font font-meslo-lg-nerd-font font-poppins
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
   - Privacy & Security > Accessibility: allow SketchyBar, so a click on the CPU or memory
     percentage can pick the tab of Activity Monitor
   - Privacy & Security > Automation: allow AeroSpace and Ghostty to control System Events, so
     the bar hides the menu bar when it starts (it runs under AeroSpace), and the bar's off button
     and `space off` show it (macOS asks the first time)

4. macOS: open Karabiner-Elements and follow its setup: turn on its driver in System Settings >
   General > Login Items & Extensions > Driver Extensions, allow Input Monitoring, choose the ANSI
   keyboard type (ISO swaps @ and <, even on a French ISO keyboard). Right command now drives
   AeroSpace (keys at the top of `aerospace/aerospace.toml`), and option-fn switches the layout
   (fn alone does nothing).

5. macOS: let the coffee in the bar, and the `coffee` and `tisane` aliases, switch sleep without a
   password (without this rule, a click on the coffee asks for it in a dialog):

   ```sh
   echo "$USER ALL=(root) NOPASSWD: /usr/bin/pmset -a disablesleep 0, /usr/bin/pmset -a disablesleep 1" |
       sudo tee /etc/sudoers.d/pmset-disablesleep >/dev/null
   sudo chmod 440 /etc/sudoers.d/pmset-disablesleep && sudo visudo -c
   ```

## Commands

`dotfiles install`, `dotfiles update` and `dotfiles status` are described in
[AGENTS.md](AGENTS.md#commands-bindotfiles-on-path-via-zshzshrc). After merging a pull request,
`make` in the repo goes back to main and runs `dotfiles update`.

macOS: `space` restarts the window manager (AeroSpace, the bar and the borders), and the bar hides
the menu bar again; `space off` stops it and shows the menu bar, as does the button left of the
Apple menu in the bar.

## Project structure

```
bin/        the dotfiles and space commands
platforms/  scheduling, notifications and the files to link, per OS
zsh/        zshrc
ghostty/    Ghostty config
superfile/  superfile config
theme/      colors and font of every tool
aerospace/  AeroSpace config (macOS)
sketchybar/ SketchyBar config and plugins (macOS)
borders/    JankyBorders config (macOS)
karabiner/  Karabiner-Elements config: right command as the AeroSpace key (macOS)
tests/      tests/run
```

## Documentation

- [AGENTS.md](AGENTS.md): the macOS window manager, how update treats a repo, adding a file, a repo
  or a platform, verifying
- [theme/AGENTS.md](theme/AGENTS.md): the theme command and its palettes

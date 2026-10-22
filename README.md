# dotfiles

My development environment (zsh, Ghostty, Neovim, Claude Code, the shared theme), linked into place
and kept up to date on every machine, macOS and Linux.

## Prerequisites

- git, zsh, and an SSH key added to GitHub (for pushing)
- Neovim and Ghostty: see the [nvim README](https://github.com/ilianusss/nvim) for what it needs

## Getting started

1. Clone the repo and run the install:

   ```sh
   git clone git@github.com:ilianusss/dotfiles.git ~/.dotfiles
   ~/.dotfiles/bin/dotfiles install
   ```

2. Open a new shell. `dotfiles update` now runs every 15 minutes and at login.

## Commands

`dotfiles install`, `dotfiles update` and `dotfiles status` are described in
[AGENTS.md](AGENTS.md#commands-bindotfiles-on-path-via-zshzshrc).

## Project structure

```
bin/        the dotfiles command
platforms/  scheduling and notifications per OS
zsh/        zshrc
ghostty/    Ghostty config
theme/      colors and font of every tool
tests/      tests/run
```

## Documentation

- [AGENTS.md](AGENTS.md): how update treats a repo, adding a file, a repo or a platform, verifying
- [theme/AGENTS.md](theme/AGENTS.md): the theme command and its palettes

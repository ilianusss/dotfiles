# ~/.dotfiles

The development environment, the same on every machine (macOS and Linux): config files linked from
this repo, a few repos cloned in place, all kept up to date by `dotfiles update` every 15 minutes.
On macOS it adds the window manager: AeroSpace, SketchyBar, JankyBorders and Karabiner-Elements.

## Commands (`bin/dotfiles`, on PATH via zsh/zshrc)

```sh
dotfiles install   # clone what is missing, link the files, apply the theme, schedule `update`
dotfiles update    # fast-forward every repo to its upstream; local work is never touched
dotfiles status    # uncommitted or unpushed work per repo, and files that are not linked
```

`install` is safe to rerun: it skips what is in place and moves a file in the way to
`<file>.bak.<time>`, never deletes it. `update` reruns the pulled `install` whenever this repo
changes, so a file or repo added here reaches every machine.

## Layout

```
bin/dotfiles          the command; LINKS, REPOS and ZSH_DEPS at its top
platforms/<os>.zsh    schedule() and notify() for one OS: darwin (launchd), linux (systemd timer),
                      and the LINKS only that OS needs
zsh/zshrc             -> ~/.zshrc; machine-only lines go in the untracked ~/.zshrc.local
ghostty/config.ghostty -> ~/.config/ghostty/config.ghostty (read on macOS too)
theme/                -> ~/.theme: colors and font of every tool, see theme/AGENTS.md
aerospace/            aerospace.toml -> ~/.config/aerospace/ (macOS): the tiling window manager
sketchybar/           -> ~/.config/sketchybar (macOS): the bar, sketchybarrc + plugins/
borders/bordersrc     -> ~/.config/borders/bordersrc (macOS): the focused window's border
karabiner/            -> ~/.config/karabiner (macOS): fn as the AeroSpace key
tests/                tests/run and the test_* functions of tests/*.zsh
```

Repos kept up to date, each with its own history: `ilianusss/nvim` in `~/.config/nvim` and
`ilianusss/.claude` in `~/.claude`. oh-my-zsh and its plugins are only cloned when missing.

## Window manager (macOS)

- AeroSpace tiles the windows (`aerospace/aerospace.toml`, its header lists the keys). It starts at
  login and starts SketchyBar and JankyBorders. The keys use `ctrl-alt`: `alt` alone types
  `{ } [ ] |` on an AZERTY Mac. AeroSpace binds physical keys, so they are the same on AZERTY and
  QWERTY.
- Karabiner-Elements makes fn the one key to hold: `karabiner/karabiner.json` turns fn + each
  AeroSpace key into ctrl-alt + that key, so a key added to `aerospace.toml` gets a line there too.
  It also makes option-fn switch between the French and U.S. layouts, and fn alone do nothing: the
  macOS setting for fn alone ignores a value written with `defaults`. The whole folder is linked,
  not the file: Karabiner stops seeing changes to a linked `karabiner.json`, and it rewrites the
  file when its settings are changed in its app. It is plain JSON, edited by hand: no comments, so
  every rule says what it does in its `description`. Karabiner reloads it on save.
- On every workspace change, and after a window is sent to another workspace, AeroSpace triggers
  the `aerospace_workspace_change` event; `sketchybar/plugins/spaces.zsh` then redraws the
  workspaces of each display.
- Colors and font follow the theme: `theme/targets/sketchybar.zsh` and `theme/targets/borders.zsh`
  render `~/.theme/generated/{sketchybar,borders}`, sourced by `sketchybarrc` and `bordersrc`.
- The bar is 32 px high (`sketchybarrc`), and AeroSpace leaves it `gaps.outer.top = 40`: change
  both together.
- Installing the apps and the macOS settings they need is manual: see the README.

## How `update` treats a repo

- Fetches over HTTPS (the repos are public, the scheduled run has no SSH agent); remotes stay SSH.
- Fast-forward only. Local commits that diverge, or a local change the update would overwrite,
  leave the repo as is: logged every run, notified once per upstream commit.
- Unpushed commits with nothing to pull: left alone, silently. Pushing is manual.
- After a pull: submodules checked out, `Lazy! restore` when `lazy-lock.json` changed, the pulled
  `dotfiles install` when this repo changed.
- No network: logged, not notified. One update at a time (lock in the state folder).
- Log and state: `~/.local/state/dotfiles/` (`update.log`, `blocked/`).

## Adding

- A config file: put it in a folder named after the tool, add a line to `LINKS`. A file only one OS
  uses goes in `LINKS+=(...)` at the top of `platforms/<os>.zsh` instead, so the other OS neither
  links it nor reports it in `status`. Its colors and font come from `~/.theme` (theme/AGENTS.md).
- A repo to keep up to date: add `url path` to `REPOS`. If a pulled change needs a step to take
  effect, add it to `after_pull`.
- A platform: `platforms/<uname -s, lowercase>.zsh` defining `schedule` and `notify`. A Linux distro
  that needs more (packages, another notifier) gets `platforms/linux-<ID>.zsh`, `ID` from
  `/etc/os-release`: it is picked before `linux.zsh` and can `source` it.

## Conventions

- zsh, in the style of `theme/bin/theme`: `emulate -L zsh`, small functions, no comment that
  restates the code.
- Nothing is copied into place: every config is a link, so editing it edits the repo.
- Nothing the user owns is deleted or overwritten: back it up, skip it, or report it.

## Verify

```sh
zsh -n bin/dotfiles platforms/*.zsh tests/run tests/*.zsh   # syntax
tests/run                                                   # every test, in throwaway repos
dotfiles status
tail ~/.local/state/dotfiles/update.log
launchctl print gui/$UID/com.github.ilianusss.dotfiles      # macOS: the scheduled agent
systemctl --user list-timers dotfiles-update.timer          # Linux: the timer
```

macOS window manager:

```sh
zsh -n sketchybar/sketchybarrc sketchybar/plugins/*.zsh borders/bordersrc
aerospace reload-config && aerospace list-workspaces --all  # AeroSpace accepts its config
sketchybar --reload && sketchybar --query bar               # the bar runs with the theme colors
python3 -m json.tool karabiner/karabiner.json >/dev/null    # valid JSON
tail /var/log/karabiner/core_service.log                    # "core_configuration is updated"
```

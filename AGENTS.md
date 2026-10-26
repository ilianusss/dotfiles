# ~/.dotfiles

The development environment, the same on every machine (macOS and Linux): config files linked from
this repo, a few repos cloned in place, all kept up to date by `dotfiles update` every 15 minutes.

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
tests/                tests/run and the test_* functions of tests/*.zsh
```

Repos kept up to date, each with its own history: `ilianusss/nvim` in `~/.config/nvim` and
`ilianusss/.claude` in `~/.claude`. oh-my-zsh and its plugins are only cloned when missing.

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
  links it nor reports it in `status`.
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

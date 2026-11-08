# make, or make main: back to main and up to date. `dotfiles update` is the pull (fast-forward
# only) and reruns `dotfiles install` when it brings changes, so a file a merged PR added gets
# linked; a `git pull` before it would leave it nothing to pull, and install would not run.

.PHONY: main

main:
	git checkout main
	bin/dotfiles update

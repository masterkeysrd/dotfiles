# Dot Files

This repository contains my dot files, which are used to configure my computer
in a way that I like. The files are organized in a way that makes it easy to
install them on a new machine.

## Installation

Clone the repository as bare repo and set it up in your `$HOME` directory.

```bash
git clone --bare git@github.com:masterkeysrd/dotfiles.git .dotfiles
git --git-dir=$HOME/.dotfiles --work-tree=$HOME checkout -f
```

> NOTE: The install script is not ready yet. It is still a work in progress.

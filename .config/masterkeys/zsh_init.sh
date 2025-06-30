# This file initializes the ZSH shell with the custom prompt.
#
# This file is sourced in the .zshrc file

start_tmux() {
  tmux attach -t default || tmux new -s default
}

# Start TMUX session, if not already running
if [ -z "$TMUX" ]; then
  start_tmux
fi

load_localrc() {
  # Check if .localrc exists and source it
  # This file is used to store local environment variables
  # It is not tracked by git
  if [ -f ~/.localrc ]; then
    source ~/.localrc
  fi
}

load_localrc

# Custom commands.
clear() {
    command clear
    if [[ -n "$TMUX" ]]; then
        tmux clear-history
    fi
}

function lg() {
  if [[ "$PWD" == "$HOME" ]]; then
    # LazyGit for dotfiles bare repo
    lazygit --git-dir="$HOME/.dotfiles" --work-tree="$HOME"
  else
    # Normal lazygit
    lazygit
  fi
}


## Alias

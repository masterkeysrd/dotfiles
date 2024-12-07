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

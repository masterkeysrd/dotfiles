# Init script for zsh
eval "$(/opt/homebrew/bin/brew shellenv)"

# Go setup
export GOENV_ROOT="$HOME/.goenv"
export PATH="$GOENV_ROOT/bin:$PATH"
export PATH="$GOROOT/bin:$PATH"
export PATH="$PATH:$GOPATH/bin"
eval "$(goenv init -)"

# Maven setup
export M2_HOME="$HOME/Applications/apache-maven-3.9.6"
export PATH="$M2_HOME/bin:${PATH}"

# Java setup
export JAVA_HOME=$(/usr/libexec/java_home)

# Node setup
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

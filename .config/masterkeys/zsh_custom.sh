# This file customizes the prompt and the colors of the terminal
# The colors are based on the Rose Pine theme
#
# This file is sourced in the .zshrc file

base_moon=234
rose_moon=217
pine_moon=74
gold_moon=220
iris_moon=135
surface_moon=235

branch_icon="\ue0a0"
detached_icon="\u27a6"
plusminus_icon="\u00b1"

prompt_context() {
  if [[ "$USER" != "$DEFAULT_USER" || -n "$SSH_CLIENT" ]]; then
    prompt_segment $surface_moon default "👻"
  fi
}

prompt_dir() {
  prompt_segment $rose_moon $base_moon "%3~"
}

prompt_git() {
  local bg_color fg_color ref
  is_dirty() {
    test -n "$(git status --porcelain --ignore-submodules)"
  }

  ref=$(git symbolic-ref --short HEAD 2>/dev/null) || ref=$(git rev-parse --short HEAD 2>/dev/null) || ref=$(git rev-parse --short --verify HEAD 2>/dev/null)
  if [[ -n $ref ]]; then
    bg_color=$surface_moon
    if is_dirty; then
      fg_color=$rose_moon
      ref="$ref $plusminus_icon"
    else
      fg_color=$pine_moon
      ref="$ref"
    fi

    if [[ "${ref/.../}" == "$ref" ]]; then
      ref="$branch_icon $ref"
    else
      ref="$detached_icon $ref"
    fi

    prompt_segment $bg_color $fg_color
    print -n "$ref"
  fi
}

# Declare the variable
# More info at https://github.com/zsh-users/zsh-syntax-highlighting/blob/master/docs/highlighters/main.md
typeset -A ZSH_HIGHLIGHT_STYLES

# To change the style of the command based on the return code
ZSH_HIGHLIGHT_STYLES[builtin]="fg=${pine_moon}"

# To differentiate aliases from other command types
ZSH_HIGHLIGHT_STYLES[alias]="fg=${rose_moon}"

# To have the command in a different color
ZSH_HIGHLIGHT_STYLES[command]="fg=${iris_moon}"

# To have reserved words in a different color
ZSH_HIGHLIGHT_STYLES['reserved-word']="fg=${gold_moon}"

# To further differentiate environment variables
ZSH_HIGHLIGHT_STYLES[function]="fg=${rose_moon}"

# To have paths colored instead of underlined
ZSH_HIGHLIGHT_STYLES[path]='fg=white,underline'

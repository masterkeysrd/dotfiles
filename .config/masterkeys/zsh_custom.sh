# This file customizes the prompt and the colors of the terminal
# The colors are based on the Rose Pine theme
#
# This file is sourced in the .zshrc file

branch_icon="\ue0a0"
detached_icon="\u27a6"
plusminus_icon="\u00b1"


canvas_subtle=234
success_fg=69

scale_green_03=77
scale_red_04=210
scale_purple_03=183
scale_orange_03=215


prompt_context() {
  if [[ "$USER" != "$DEFAULT_USER" || -n "$SSH_CLIENT" ]]; then
    prompt_segment $canvas_subtle default "👻"
  fi
}

prompt_dir() {
  prompt_segment $scale_green_03 $canvas_subtle "%3~"
}

prompt_git() {
  local bg_color fg_color ref
  is_dirty() {
    test -n "$(git status --porcelain --ignore-submodules)"
  }

  ref=$(git symbolic-ref --short HEAD 2>/dev/null) || ref=$(git rev-parse --short HEAD 2>/dev/null) || ref=$(git rev-parse --short --verify HEAD 2>/dev/null)
  if [[ -n $ref ]]; then
    bg_color=$canvas_subtle
    if is_dirty; then
      fg_color=$success_fg
      ref="$ref $plusminus_icon"
    else
      fg_color=$scale_green_03
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
ZSH_HIGHLIGHT_STYLES[builtin]="fg=${scale_red_04}"

# To differentiate aliases from other command types
ZSH_HIGHLIGHT_STYLES[alias]="fg=${scale_purple_03}"

# To have the command in a different color
ZSH_HIGHLIGHT_STYLES[command]="fg=${scale_purple_03}"

# To have reserved words in a different color
ZSH_HIGHLIGHT_STYLES['reserved-word']="fg=${scale_red_04}"

# To further differentiate environment variables
ZSH_HIGHLIGHT_STYLES[function]="fg=${scale_purple_03}"

# To have paths colored instead of underlined
ZSH_HIGHLIGHT_STYLES[path]='fg=white,underline'

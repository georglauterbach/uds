#! /usr/bin/env bash

# version       0.4.0
# sourced by    ${HOME}/.bashrc
# task          provides Bash's main setup

function setup_misc() {
  shopt -s histappend checkwinsize globstar autocd
}

function setup_variables() {
  export VISUAL='nvim'
  export EDITOR=${VISUAL}
  export PAGER='less -R'

  if ! __command_exists ble; then
    export HISTCONTROL='ignoreboth'
    export HISTSIZE=10000
    export HISTFILESIZE=10000
  fi

  if __command_exists batcat; then
    export MANPAGER="sh -c 'col -bx | batcat -l man --style=plain --theme=gruvbox-dark'"
    export MANROFFOPT='-c'
    export BAT_PAGER=${PAGER}
  fi
}

function setup_completion() {
  if ! shopt -oq posix; then
    if [[ -f /usr/share/bash-completion/bash_completion ]]; then
      # shellcheck source=/dev/null
      source /usr/share/bash-completion/bash_completion
    elif [[ -f /etc/bash_completion ]]; then
      # shellcheck source=/dev/null
      source /etc/bash_completion
    fi

    if __command_exists doas; then
      complete -cf doas
      alias sudo='doas'
    fi
  fi
}

function setup_prompt() {
  export PROMPT_DIRTRIM=4

  if ! __command_exists ble; then
    PS2=''         # continuation shell prompt
    PS4='[TRACE] ' # `set -x` tracing prompt
  fi

  if ! __command_exists starship && [[ -v debian_chroot ]] && [[ -r /etc/debian_chroot ]]; then
    # shellcheck disable=SC2155
    export debian_chroot=$(</etc/debian_chroot)
  fi
}

for __FUNCTION in 'misc' 'variables' 'completion' 'prompt'; do
  "setup_${__FUNCTION}"
  unset "setup_${__FUNCTION}"
done

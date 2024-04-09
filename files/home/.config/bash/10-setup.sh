#! /usr/bin/env bash

# version       0.5.0
# sourced by    ${HOME}/.bashrc
# task          provide Bash's main setup

function setup_misc() {
  shopt -s histappend checkwinsize globstar autocd
}

function setup_path() {
  local PATHS=(
    "${HOME}/bin"
    "${HOME}/.local/bin"
    "${HOME}/.fzf/bin"
  )

  for LOCAL_PATH in "${PATHS[@]}"; do
    if [[ -d ${LOCAL_PATH} ]] && [[ ${PATH} != *${LOCAL_PATH}* ]]; then
      export PATH="${LOCAL_PATH}${PATH:+:${PATH}}"
    fi
  done

  local SOURCE_PATHS=(
    "${HOME}/.cargo/env"
  )

  for LOCAL_PATH in "${SOURCE_PATHS[@]}"; do
    # shellcheck source=/dev/null
    [[ -e ${LOCAL_PATH} ]] && [[ -r ${LOCAL_PATH} ]] && source "${LOCAL_PATH}"
  done

  return 0
}

function setup_variables() {
  VISUAL='nano'
  __command_exists 'vi' && VISUAL='vi'
  __command_exists 'vim' && VISUAL='vim'
  __command_exists 'nvim' && VISUAL='nvim'

  EDITOR=${VISUAL}
  PAGER="$(command -v less) -R"
  GPG_TTY=$(tty)

  export VISUAL EDITOR PAGER GPG_TTY

  if ! __command_exists 'ble'; then
    export HISTCONTROL='ignoreboth'
    export HISTSIZE=10000
    export HISTFILESIZE=10000
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

    if __command_exists 'doas'; then
      complete -cf doas
      alias sudo='doas'
    fi
  fi
}

function setup_prompt() {
  export PROMPT_DIRTRIM=4

  # disable blinking cursor (e.g., in TMUX)
  printf '\033[2 q'

  PS2=''  # continuation shell prompt
  PS4='> ' # `set -x` tracing prompt

  if ! __command_exists 'starship' && [[ -v debian_chroot ]] && [[ -r /etc/debian_chroot ]]; then
    # shellcheck disable=SC2155
    export debian_chroot=$(</etc/debian_chroot)
  fi
}

for __FUNCTION in 'misc' 'path' 'variables' 'completion' 'prompt'; do
  "setup_${__FUNCTION}"
  unset "setup_${__FUNCTION}"
done

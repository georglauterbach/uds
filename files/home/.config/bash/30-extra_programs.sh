#! /usr/bin/env bash

# version       0.1.0
# sourced by    ${HOME}/.bashrc
# task          setup up miscellaneous programs
#               if they are installed

function setup_fzf() {
  if [[ -d ${HOME}/.fzf ]]
  then
    PATH="${PATH:-}:${HOME}/.fzf/bin"
    if [[ ${-} == *i* ]]
    then
      source "${HOME}/.fzf/shell/completion.bash" 2>/dev/null
      source "${HOME}/.fzf/shell/key-bindings.bash"
    fi
  fi
}

function setup_rust() {
  if [[ -d ${HOME}/.cargo ]]
  then
    source "${HOME}/.cargo/env"
  fi
}

function setup_ble() {
  local BLE_SOURCE="${HOME}/.local/share/blesh/ble.sh"
  if [[ -e ${BLE_SOURCE} ]]
  then
    local BLE_CONFIG_FILE="${HOME}/.config/bash/ble.sh"
    if [[ -e ${BLE_CONFIG_FILE} ]]
    then
      source "${BLE_SOURCE}" --noattach --rcfile "${BLE_CONFIG_FILE}"
    else
      source "${BLE_SOURCE}" --noattach
    fi
  fi
}

function setup_misc_programs() {
  if command -v just &>/dev/null
  then
    alias j='just'
    complete -F _just -o bashdefault -o default j
  fi

  if command -v kubectl &>/dev/null
  then
    alias k='kubectl'
    complete -o default -F __start_kubectl k
  fi

  if command -v polybar &>/dev/null
  then
    alias rp='killall polybar && ${HOME}/.config/polybar/launch.sh'
  fi
}

setup_fzf
setup_rust
setup_ble
setup_misc_programs

unset setup_fzf
unset setup_rust
unset setup_ble
unset setup_misc_programs

#! /usr/bin/env bash

# ██████╗  █████╗ ███████╗██╗  ██╗    ███████╗
# ██╔══██╗██╔══██╗██╔════╝██║  ██║    ██╔════╝
# ██████╔╝███████║███████╗███████║    ███████╗
# ██╔══██╗██╔══██║╚════██║██╔══██║    ╚════██║
# ██████╔╝██║  ██║███████║██║  ██║    ███████║
# ╚═════╝ ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝    ╚══════╝

# version       1.5.0
# executed by   Bash for non-login shells
# task          shell (Bash) initialization

function bash_setup() {
  # if not running interactively, don't do anything
  [[ ${-} != *i* ]] && return 0

  function load_helper() {
    local SETUP_FILE="${HOME}/.config/bash/${1}"
    # shellcheck source=/dev/null
    [[ -e ${SETUP_FILE} ]] && [[ -r ${SETUP_FILE} ]] && source "${SETUP_FILE}"
    return 0
  }

  load_helper '00-base.sh'
  load_helper '10-setup.sh'
  load_helper '30-extra_programs.sh'
  load_helper '80-aliases.sh'
  load_helper '90-wrapper.sh'
  load_helper '99-custom.sh'

  if command -v starship &>/dev/null; then
    export STARSHIP_CONFIG="${HOME}/.config/bash/starship.toml"
    eval "$(starship init bash || :)"
  fi

  [[ -v BLE_VERSION ]] && ble-attach
}

bash_setup "${@}"
unset bash_setup

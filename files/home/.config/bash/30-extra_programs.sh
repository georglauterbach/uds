#! /usr/bin/env bash

# version       0.3.0
# sourced by    ${HOME}/.bashrc
# task          setup up miscellaneous programs if they are installed

function setup_fzf() {
  if [[ ${-} == *i* ]] && [[ -d ${HOME}/.fzf ]]; then
    # shellcheck source=/dev/null
    source "${HOME}/.fzf/shell/completion.bash" 2>/dev/null
    # shellcheck source=/dev/null
    source "${HOME}/.fzf/shell/key-bindings.bash"
  fi
}

function setup_rust() {
  __command_exists sccache && export RUSTC_WRAPPER='sccache'
}

function setup_misc_programs() {
  local BAT_NAME='batcat' # use 'bat' on older distributions
  if __command_exists "${BAT_NAME}"; then
    export MANPAGER="bash -c 'col -bx | ${BAT_NAME} -l man --style=plain --theme=gruvbox-dark'"
    export MANROFFOPT='-c'
    # `PAGER` is set in `10-setup.sh`
    # shellcheck disable=SC2154
    export BAT_PAGER=${PAGER}
    # make sure `PAGER` is set before this alias is defined
    # shellcheck disable=SC2139
    alias less="${BAT_NAME} --style=plain --paging=always --color=always --theme=gruvbox-dark"
  fi

  if __command_exists zoxide; then
    eval "$(zoxide init bash)"
    alias cd='z'
  fi

  if __command_exists 'starship'; then
    STARSHIP_CONFIG="${HOME}/.config/bash/starship.toml"
    if [[ -f ${STARSHIP_CONFIG} ]] && [[ -r ${STARSHIP_CONFIG} ]]; then
      export STARSHIP_CONFIG
    else
      unset STARSHIP_CONFIG
    fi
  fi
}

function setup_ble() {
  local BLE_SOURCE="${HOME}/.local/share/blesh/ble.sh"
  if [[ -e ${BLE_SOURCE} ]]; then
    local BLE_CONFIG_FILE="${HOME}/.config/bash/ble.conf"
    if [[ -e ${BLE_CONFIG_FILE} ]]; then
      # shellcheck source=/dev/null
      source "${BLE_SOURCE}" --attach=none --rcfile "${BLE_CONFIG_FILE}"
    else
      # shellcheck source=/dev/null
      source "${BLE_SOURCE}" --attach=none
    fi

    if __command_exists 'fzf'; then
      ble-import -d integration/fzf-completion
      ble-import -d integration/fzf-key-bindings
    fi

    if __command_exists 'zoxide'; then
      ble-import -f integration/zoxide
    fi
  fi
}

for __FUNCTION in 'fzf' 'rust' 'misc_programs' 'ble'; do
  "setup_${__FUNCTION}"
  unset "setup_${__FUNCTION}"
done

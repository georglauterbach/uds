#! /usr/bin/env bash

# version       0.3.0
# sourced by    ${HOME}/.bashrc
# task          setup up miscellaneous programs if they are installed

function setup_fzf() {
  export PATH="${PATH:-}:${HOME}/.fzf/bin"
  if [[ ${-} == *i* ]] && [[ -d ${HOME}/.fzf ]]; then
    # shellcheck source=/dev/null
    source "${HOME}/.fzf/shell/completion.bash" 2>/dev/null
    # shellcheck source=/dev/null
    source "${HOME}/.fzf/shell/key-bindings.bash"
  fi
}

function setup_rust() {
  if [[ -d ${HOME}/.cargo ]]; then
    # shellcheck source=/dev/null
    source "${HOME}/.cargo/env"
    __command_exists sccache && export RUSTC_WRAPPER='sccache'
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

    if __command_exists fzf; then
      ble-import -d integration/fzf-completion
      ble-import -d integration/fzf-key-bindings
    fi
  fi
}

function setup_misc_programs() {
  if __command_exists batcat; then
    export MANPAGER="bash -c 'col -bx | batcat -l man --style=plain --theme=gruvbox-dark'"
    export MANROFFOPT='-c'
    # `PAGER` is set in `10-setup.sh`
    # shellcheck disable=SC2154
    export BAT_PAGER=${PAGER}
    # make sure `PAGER` is set before this alias is defined
    alias less='batcat --style=plain --paging=always --color=always --theme=gruvbox-dark'
  fi

  if __command_exists kubectl; then
    alias k='kubectl'
    complete -o default -F __start_kubectl k
  fi

  if __command_exists polybar; then
    alias rp='killall polybar && ${HOME}/.config/polybar/launch.sh'
  fi

  if __command_exists btop; then
    alias htop='btop'
  fi

  if __command_exists 'gitui'; then
    alias g='gitui'
  else
    alias g='git diff'
  fi

}

for __FUNCTION in 'fzf' 'rust' 'ble' 'misc_programs'; do
  "setup_${__FUNCTION}"
  unset "setup_${__FUNCTION}"
done

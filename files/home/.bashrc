#! /bin/bash

# ██████╗  █████╗ ███████╗██╗  ██╗    ███████╗
# ██╔══██╗██╔══██╗██╔════╝██║  ██║    ██╔════╝
# ██████╔╝███████║███████╗███████║    ███████╗
# ██╔══██╗██╔══██║╚════██║██╔══██║    ╚════██║
# ██████╔╝██║  ██║███████║██║  ██║    ███████║
# ╚═════╝ ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝    ╚══════╝

# version       1.3.0
# executed by   Bash for non-login shells
# task          shell (Bash) initialization

function bash_setup
{
  # if not running interactively,
  # don't do anything
  [[ ! ${-} == *i* ]] && return 0

  function load_helper
  {
    local SETUP_FILE="${HOME}/.config/bash/${1}"

    # shellcheck source=/dev/null
    [[ -e ${SETUP_FILE} ]] && source "${SETUP_FILE}"
  }

  load_helper '10-setup.sh'
  load_helper '80-aliases.sh'
  load_helper '90-wrapper.sh'

  unset load_helper
  if command -v starship &>/dev/null
  then
    export STARSHIP_CONFIG="${HOME}/.config/bash/starship.toml"
    eval "$(starship init bash)"
  fi
}

bash_setup "${@}"
unset bash_setup

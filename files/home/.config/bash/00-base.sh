#! /usr/bin/env bash

# version       0.2.0
# sourced by    ${HOME}/.bashrc
# task          set up functions required during setup

if ! type -t '__command_exists' &>/dev/null; then
  function __command_exists() {
    command -v "${1:?Command name is required}" &>/dev/null
  }

  readonly -f __command_exists
  export -f __command_exists
fi

function __is_bash_function() {
  [[ $(type -t "${1:?Name of type to check is required}" || :) == 'function' ]]
}

function __uds__declare_helpers() {
  declare -f do_as_root          \
    __uds__execute_real_command  \
    __command_exists             \
    __is_bash_function
}

function __uds__execute_real_command() {
  local COMMAND DIR FULL_COMMAND
  COMMAND=${1:?Command name required}
  shift 1

  for DIR in ${PATH//:/ }; do
    FULL_COMMAND="${DIR}/${COMMAND}"
    [[ -x ${FULL_COMMAND} ]] && { ${FULL_COMMAND} "${@}" ; return ${?} ; }
  done

  echo "Command '${COMMAND}' not found" >&2
  return 1
}

function do_as_root() {
  local SU_COMMAND

  if __command_exists 'doas'; then
    SU_COMMAND='doas'
  elif __command_exists 'sudo'; then
    SU_COMMAND='sudo'
  else
    echo 'Could not find program to execute command as root'
    return 1
  fi

  if __is_bash_function "${1:?Command is required}"; then
    ${SU_COMMAND} bash -c "$(__uds__declare_helpers || :) ; ${*}"
  else
    ${SU_COMMAND} "${@}"
  fi
}
export -f do_as_root

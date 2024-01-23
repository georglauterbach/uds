#! /usr/bin/env bash

# version       0.1.4
# sourced by    ${HOME}/.bashrc
# task          provides helper and wrapper functions
#               for common tasks and commands

function __uds__declare_with_helpers() {
  declare -f "${@}"              \
    __uds__split_into_array      \
    __uds__is_bash_function      \
    __uds__command_exists        \
    __uds__execute_real_command  \
    do_as_root
}

# ref: https://stackoverflow.com/a/45201229
function __uds__split_into_array() {
  local ARRAY_NAME=${1:?Array name is required}
  local STRING_TO_SPLIT=${2:?String to split is required}
  local DELIMITER=${3:-:}

  readarray \
    -t -d '' \
    "${ARRAY_NAME}" \
    < <(awk "{ gsub(/${DELIMITER}/,\"\0\"); print; }" <<< "${STRING_TO_SPLIT}${DELIMITER}")
  unset 'a[-1]'
}

function __uds__is_bash_function() {
  [[ $(type -t "${1:?Name of type to check is required}") == 'function' ]]
}

function __uds__command_exists() {
  command -v "${1:-}" &>/dev/null
}

function __uds__execute_real_command() {
  local COMMAND POSSIBLE_PATHS DIR FULL_COMMAND
  COMMAND=${1:?Command name required}
  shift 1

  __uds__split_into_array POSSIBLE_PATHS "${PATH}"
  for DIR in "${POSSIBLE_PATHS[@]}"
  do
    FULL_COMMAND="${DIR}/${COMMAND}"
    [[ -x ${FULL_COMMAND} ]] && { ${FULL_COMMAND} "${@}" ; return ${?} ; }
  done

  echo "Command '${COMMAND}' not found" >&2
  return 1
}

function do_as_root() {
  local SU_COMMAND

  if __uds__command_exists 'doas'
  then
    SU_COMMAND='doas'
  elif __uds__command_exists 'sudo'
  then
    SU_COMMAND='sudo'
  else
    echo 'Could not find program to execute command as root'
    return 1
  fi

  if __uds__is_bash_function "${1:?Command is required}"
  then
    ${SU_COMMAND} bash -c "$(__uds__declare_with_helpers "${1}") ; ${*}"
  else
    ${SU_COMMAND} "${@}"
  fi
}

function ls() {
  if __uds__command_exists 'eza'
  then
    eza --header --long --binary --group --classify --git --extended --group-directories-first "${@}"
  else
    __uds__execute_real_command 'ls' "${@}"
  fi
}

function cat() {
  if __uds__command_exists 'batcat'
  then
    batcat --theme="gruvbox-dark" --paging=never --italic-text=always "${@}"
  else
    __uds__execute_real_command 'cat' "${@}"
  fi
}

function grep() {
  if __uds__command_exists 'rg'
  then
    rg -N "${@}"
  else
    __uds__execute_real_command 'grep' "${@}"
  fi
}

function git() {
  case "${1:-}" in
    ( 'update' )
      git fetch --all --tags --prune
      git pull
      git submodule update
      ;;
    ( * ) __uds__execute_real_command git "${@}" ;;
  esac
}

function apt() {
  local PROGRAM='apt'
  __uds__command_exists 'nala' && PROGRAM='nala'

  if [[ ${1:-} =~ ^show|search$ ]]
  then
    __uds__execute_real_command "${PROGRAM}" "${@}"
  else
    do_as_root "${PROGRAM}" "${@}"
  fi
}

function shutn { shutdown now ; }

# stolen, ahh adopted from
# https://github.com/casperklein/bash-pack/blob/master/x
function x() {
  [[ -f ${1:-} ]] || { echo "File '${1:-}' not found" >&2 ; return 1 ; }

  case "${1}" in
    ( *.7z )      7za x "${1}"       ;;
    ( *.ace )     unace e "${1}"     ;;
    ( *.tar.bz2 ) bzip2 -v -d "${1}" ;;
    ( *.bz2 )     bzip2 -d "${1}"    ;;
    ( *.deb )     ar -x "${1}"       ;;
    ( *.tar.gz )  tar -xvzf "${1}"   ;;
    ( *.gz )      gunzip -d "${1}"   ;;
    ( *.lzh )     lha x "${1}"       ;;
    ( *.rar )     unrar x "${1}"     ;;
    ( *.shar )    sh "${1}"          ;;
    ( *.tar )     tar -xvf "${1}"    ;;
    ( *.tbz2 )    tar -jxvf "${1}"   ;;
    ( *.tgz )     tar -xvzf "${1}"   ;;
    ( *.xz )      xz -dv "${1}"      ;;
    ( *.zip )     unzip "${1}"       ;;
    ( *.Z )       uncompress "${1}"  ;;
    ( * )
      echo "Compression type for file '${1}' unknown" >&2
      return 1
      ;;
  esac
}

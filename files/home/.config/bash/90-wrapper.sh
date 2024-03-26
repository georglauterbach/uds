#! /usr/bin/env bash

# version       0.3.1
# sourced by    ${HOME}/.bashrc
# task          provides helper and wrapper functions
#               for common tasks and commands

function ls() {
  if __command_exists 'eza'; then
    eza --header --long --binary --group --classify --git --extended --group-directories-first "${@}"
  else
    __uds__execute_real_command 'ls' "${@}"
  fi
}

function cat() {
  if __command_exists 'batcat'; then
    batcat --theme="gruvbox-dark" --paging=never --italic-text=always "${@}"
  else
    __uds__execute_real_command 'cat' "${@}"
  fi
}

function grep() {
  if __command_exists 'rg'; then
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
      git submodule update --recursive
      ;;
    ( * ) __uds__execute_real_command git "${@}" ;;
  esac
}

function apt() {
  local PROGRAM='apt'
  __command_exists 'nala' && PROGRAM='nala'

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

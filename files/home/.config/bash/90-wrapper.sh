#! /bin/bash

# version       0.1.2
# sourced by    ${HOME}/.bashrc
# task          provides helper and wrapper functions
#               for common tasks and commands

function execute_real_command() {
  local DIR FULL_COMMAND PATHS
  readarray -d ':' PATHS <<< "${PATH}"

  for DIR in "${PATHS[@]}"
  do
    FULL_COMMAND="${DIR::-1}/${1:-}"

    if [[ -x ${FULL_COMMAND} ]]
    then
      shift 1
      ${FULL_COMMAND} "${@}"
      return ${?}
    fi
  done

  echo "Command '${1:-}' not found" >&2
  return 1
}

function command_exists() {
  command -v "${1:-}" &>/dev/null
}

function ls() {
  if command_exists exa
  then
    exa --long --binary --header --group --classify --group-directories-first "${@}"
  else
    execute_real_command ls "${@}"
  fi
}

function cat() {
  if command_exists batcat
  then
    batcat --theme="Monokai Extended Origin" --paging=never --italic-text=always "${@}"
  else
    execute_real_command cat "${@}"
  fi
}

function grep() {
  if command_exists rg
  then
    rg -N "${@}"
  else
    execute_real_command grep "${@}"
  fi
}

function git
{
  case "${1:-}" in
    ( 'update' ) gf ; gp ;;
    ( * ) execute_real_command git "${@}" ;;
  esac
}

function shutn { shutdown now ; }

# stolen, ahh adopted from
# https://github.com/casperklein/bash-pack/blob/master/x
function x
{
  [[ -f ${1:-} ]] || { printf "File '%s' not found" "${1}" >&2 ; return 1 ; }

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
      printf "Compression type for file '%s' unknown" "${1}" >&2
      return 1
      ;;
  esac

  return ${?}
}

function update() {
  # shellcheck disable=SC2317
  function __update() {
    local QUIET OPTIONS
    QUIET='-qq'
    OPTIONS=('--yes' '--assume-yes' '--allow-unauthenticated' '--allow-change-held-packages')

    echo 'Checking for package updates'
    if ! apt-get "${QUIET}" update
    then
      echo "Could not update package signatures [${?}]" >&2
      return 1
    fi

    echo 'Installing package updates'
    if ! apt-get --with-new-pkgs "${QUIET}" "${OPTIONS[@]}" upgrade
    then
      log_error "Could not upgrade packages [${?}]" >&2
      return 1
    fi

    echo 'Removing orphaned packages'
    if ! apt-get "${QUIET}" "${OPTIONS[@]}" autoremove
    then
      echo "Could not automatically remove unneeded packages [${?}]" >&2
    fi

    echo 'Successfully updated the system'
  }

  sudo -E bash -c "$(declare -f __update) ; __update"
}

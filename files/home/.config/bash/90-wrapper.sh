#! /bin/bash

# version       0.1.3
# sourced by    ${HOME}/.bashrc
# task          provides helper and wrapper functions
#               for common tasks and commands

function __execute_real_command() {
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

function __command_exists() {
  command -v "${1:-}" &>/dev/null
}

function __do_as_root() {
  if __command_exists doas
  then
    doas "${@}"
  elif __command_exists sudo
  then
    sudo "${@}"
  else
    echo 'Could not find program to execute command as root'
  fi
}

function ls() {
  if __command_exists exa
  then
    exa --long --binary --header --group --classify --group-directories-first "${@}"
  else
    __execute_real_command ls "${@}"
  fi
}

function cat() {
  if __command_exists batcat
  then
    batcat --theme="Monokai Extended Origin" --paging=never --italic-text=always "${@}"
  else
    __execute_real_command cat "${@}"
  fi
}

function grep() {
  if __command_exists rg
  then
    rg -N "${@}"
  else
    __execute_real_command grep "${@}"
  fi
}

function git() {
  case "${1:-}" in
    ( 'update' ) git fetch --all --tags --prune ; git pull ;;
    ( * ) __execute_real_command git "${@}" ;;
  esac
}

function apt() {
  if __command_exists nala
  then
    case "${1}" in
      ( 'update' | 'upgrade' | 'install' ) sudo nala "${@}" ;;
      ( * ) nala "${@}" ;;
    esac
  else
    __execute_real_command apt "${@}"
  fi
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
    local QUIET OPTIONS LOG_FILE
    QUIET='-qq'
    OPTIONS=('--yes' '--assume-yes' '--allow-unauthenticated' '--allow-change-held-packages')
    LOG_FILE=$(mktemp)

    echo -n '  -> Checking for package updates... '
    if ! apt-get "${QUIET}" update &>"${LOG_FILE}"
    then
      echo "could not update package signatures [ERROR]" >&2
      cat "${LOG_FILE}"
      return 1
    fi

    echo -ne 'done\n  -> Installing package updates... '
    if ! apt-get --with-new-pkgs "${QUIET}" "${OPTIONS[@]}" upgrad &>"${LOG_FILE}"
    then
      echo "could not upgrade packages [ERROR]" >&2
      cat "${LOG_FILE}"
      return 1
    fi

    echo -ne 'done\n  -> Removing orphaned packages... '
    if ! apt-get "${QUIET}" "${OPTIONS[@]}" autoremove &>"${LOG_FILE}"
    then
      echo "could not automatically remove orphaned packages [ERROR]" >&2
      cat "${LOG_FILE}"
    else
      echo -e 'done'
    fi

    echo -e '  -> Successfully updated the system'
    rm "${LOG_FILE}"
  }

  __do_as_root bash -c "$(declare -f __update) ; __update"
}

#! /bin/bash

# version        0.3.0
# executed by    start.sh or manually
# task           UDS main installation script

# shellcheck source=/dev/null
source <(curl -qsSfL https://raw.githubusercontent.com/georglauterbach/libbash/main/modules/log.sh)

if [[ ! $(type -t log || printf 'none') == 'function' ]]
then
  function log
  {
    shift 1 
    printf "[  LOG  ] %30s | %s" "${SCRIPT}" "${*}"
  }
fi

if [[ ${EUID} -ne 0 ]]
then
  log 'err' \
    'Please start this script with' \
    "'sudo --preserve-env=USER,HOME bash setup.sh'"
  exit 1
fi

export DEBIAN_FRONTEND=noninteractive
export DEBCONF_NONINTERACTIVE_SEEN=true

# shellcheck disable=SC2034
LOG_LEVEL=${LOG_LEVEL:-deb}
SCRIPT='UDS setup'
GITHUB_RAW_URL='https://raw.githubusercontent.com/georglauterbach/uds/dev/files/'

function __log_unexpected_error
{
  local MESSAGE='unexpected error occured { '
  MESSAGE+="script: ${SCRIPT:-${0}}"
  MESSAGE+=" | function = ${1:-none (global)}"
  MESSAGE+=" | command = ${2:-?}"
  MESSAGE+=" | line = ${3:-?}"
  MESSAGE+=" | exit code = ${4:-?}"
  MESSAGE+=" }"

  log 'err' "${MESSAGE}"
  return 0
}

trap '__log_unexpected_error "${FUNCNAME[0]:-}" "${BASH_COMMAND:-}" "${LINENO:-}" "${?:-}"' ERR
set -eEu -o pipefail
shopt -s inherit_errexit
cd /tmp || exit 1

function add_ppas
{
  log 'inf' 'Adding PPAs'

  curl -qsSfL -o /etc/apt/sources.list "${GITHUB_RAW_URL}apt/sources.list"
  curl -qsSfL -o /etc/apt/sources.list.d/uds.list "${GITHUB_RAW_URL}apt/uds.list"

  declare -a GPG_KEY_FILES

  GITHUB_URL='https://github.com/georglauterbach/uds/raw/dev/files/apt/gpg/'
  GPG_KEY_FILES=(
    alacritty
    cryptomator
    git-core
    mozillateam
    neovim-unstable
    owncloud
    regolith
    vscode
    zerotier
  )

  log 'deb' 'Adding GPG files'
  for GPG_FILE in "${GPG_KEY_FILES[@]}"
  do
    curl -qsSfL \
      -o "/etc/apt/trusted.gpg.d/${GPG_FILE}.gpg" "${GITHUB_URL}${GPG_FILE}.gpg"
  done

  log 'deb' 'Finished adding PPAs'
  log 'deb' 'Updating package signatures'
  apt-get -qq update
}

function install_packages
{
  log 'inf' 'Installing packages'

  declare -a PACKAGES
  PACKAGES=(
    'alacritty'
    'bat'
    'build-essential'
    'cmake'
    'code'
    'cryptomator'
    'cups'
    'eog'
    'evince'
    'firefox'
    'fonts-firacode'
    'fonts-font-awesome'
    'gcc'
    'gnome-calculator'
    'gnome-terminal'
    'gnome-tweaks'
    'gnupg2'
    "linux-generic-hwe-22.04"
    'make'
    'nautilus'
    'neofetch'
    'neovim'
    'owncloud-client'
    'p7zip-full'
    'polybar'
    'python3-dev'
    'python3-pynvim'
    'seahorse'
    'thunderbird'
    'thunderbird-gnome-support'
    'xsel'
    'xz-utils'
    'yaru-theme-icon'
    'yaru-theme-sound'
    'texlive-full'
  )

  # 'regolith-desktop-standard'
  # 'regolith-look-gruvbox'

  for PACKAGE in "${PACKAGES[@]}"
  do
    if dpkg-query -W --showformat='${Status}' "${PACKAGE}" \
    |& grep "install ok installed" &>/dev/null
    then
      log 'deb' "Package '${PACKAGE}' already installed"
      continue
    fi

    log 'deb' "Installing package '${PACKAGE}' now"

    if ! apt-get -qq install "${PACKAGE}"
    then
      log 'war' "Package '${PACKAGE}' could not be installed"
    fi
  done

  log 'deb' 'Installing Starship prompt'
  sh -c "$(curl -fsSL https://starship.rs/install.sh)" -- --force >/dev/null

  log 'deb' 'Finished installing packages'
}

function purge_snapd
{
  command -v snap &>/dev/null || return 0
  log 'inf' "Removing 'snapd'"
  
  rm -rf /var/cache/snapd/
  apt-get -qq purge snapd snapd gnome-software-plugin-snap
  apt-mark -qq hold snapd
  rm -rf "${HOME}/snapd"

  log 'deb' "Finished purging 'snapd'"
}

function place_configuration_files
{
  log 'inf' 'Placing configuration files'

  if ! cd "${HOME}"
  then
    log 'err' \
      'Could not change directory to home directory' \
      'Cannot place configuration files'
    return 1
  fi
  
  local GITHUB_URL
  declare -a CONFIG_FILES

  CONFIG_FILES+=('.bashrc')
  CONFIG_FILES+=('.config/bash/10-setup.sh')
  CONFIG_FILES+=('.config/bash/80-aliases.sh')
  CONFIG_FILES+=('.config/bash/90-wrapper.sh')
  CONFIG_FILES+=('.config/bash/starship.toml')

  CONFIG_FILES+=('.config/nvim/init.lua')
  CONFIG_FILES+=('.config/nvim/lua/10-plugins.lua')
  CONFIG_FILES+=('.config/nvim/lua/60-line.lua')

  CONFIG_FILES+=('.config/alacritty/alacritty.yml')
  CONFIG_FILES+=('.config/alacritty/10-general.yml')
  CONFIG_FILES+=('.config/alacritty/20-font.yml')
  CONFIG_FILES+=('.config/alacritty/30-colors.yml')
  CONFIG_FILES+=('.config/alacritty/40-bindings.yml')

  # CONFIG_FILES+=('.config/regolith/Xresources')
  # CONFIG_FILES+=('.config/regolith/wallpaper.jpg')
  # CONFIG_FILES+=('.config/regolith/i3/config')
  # CONFIG_FILES+=('.config/regolith/picom/config')
  # CONFIG_FILES+=('.config/regolith/i3xrocks/conf.d/01_setup')
  # CONFIG_FILES+=('.config/regolith/i3xrocks/conf.d/80_battery')
  # CONFIG_FILES+=('.config/regolith/i3xrocks/conf.d/80_rofication')
  # CONFIG_FILES+=('.config/regolith/i3xrocks/conf.d/90_time')

  mkdir -p \
    "${HOME}/.config/alacritty" \
    "${HOME}/.config/bash" \
    "${HOME}/.config/nvim/lua"
  
  # mkdir -p \
    # "${HOME}/.config/regolith/i3" \
    # "${HOME}/.config/regolith/picom" \
    # "${HOME}/.config/regolith/i3xrocks/conf.d"

  for FILE in "${CONFIG_FILES[@]}"
  do
    curl -qsSfL -o "${HOME}/${FILE}" "${GITHUB_RAW_URL}home/${FILE}"
  done
  
  chown "${USER}:${USER}" "${HOME}/.bashrc"
  chown -R "${USER}:${USER}" "${HOME}/.config"

  log 'deb' 'Finished placing configuration files'
}

function main
{
  log 'inf' 'Starting setup process'
  log 'war' \
    'Remember to start this script with sudo' \
    '--preserve-env=USER,HOME - press CTRL-C to abort now'
  sleep 7

  purge_snapd
  add_ppas
  install_packages
  place_configuration_files

  log 'inf' 'Finished setup process'
}

main "${@}"

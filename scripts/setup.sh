#! /bin/bash

# version        0.3.1
# executed by    manually
# task           UDS installation script

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
LOG_LEVEL=${LOG_LEVEL:-inf}
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

function purge_snapd
{
  command -v snap &>/dev/null || return 0
  log 'inf' "Removing 'snapd'"
  
  rm -rf /var/cache/snapd/
  apt-get -qq purge snapd gnome-software-plugin-snap
  apt-mark -qq hold snapd
  rm -rf "${HOME}/snapd"

  log 'deb' "Finished purging 'snapd'"
}

function add_ppas
{
  log 'inf' 'Adding PPAs'

  curl -qsSfL -o /etc/apt/sources.list "${GITHUB_RAW_URL}apt/sources.list"
  curl -qsSfL -o /etc/apt/sources.list.d/uds.list "${GITHUB_RAW_URL}apt/uds.list"

  declare -a GPG_KEY_FILES
  GPG_KEY_FILES=(
    alacritty
    cryptomator
    git-core
    mozillateam
    neovim-stable
    regolith
    vscode
    zerotier
  )

  log 'deb' 'Adding GPG files'
  for GPG_FILE in "${GPG_KEY_FILES[@]}"
  do
    curl -qsSfL \
      -o "/etc/apt/trusted.gpg.d/${GPG_FILE}.gpg" \
      "https://github.com/georglauterbach/uds/raw/dev/files/apt/gpg/${GPG_FILE}.gpg"
  done

  log 'deb' 'Finished adding PPAs'

  log 'deb' 'Overriding Firefox PPA priority to not use the Snap-package'
  curl -sSfL -o /etc/apt/preferences.d/mozillateamppa "${GITHUB_RAW_URL}apt/preferences/mozillateamppa"

  log 'deb' 'Updating package signatures'
  apt-get -qq update

}

function install_packages
{
  log 'inf' 'Installing packages'

  log 'deb' 'Applying VS Code patch'
  apt-get -qq install code
  local CODE_SOURCES_FILE='/etc/apt/sources.list.d/vscode.list'
  if [[ -e ${CODE_SOURCES_FILE} ]]
  then
    sed -i '$ d' "${CODE_SOURCES_FILE}"
    echo '#deb [arch=amd64,arm64,armhf] http://packages.microsoft.com/repos/code stable main' >"${CODE_SOURCES_FILE}"
  fi

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
    'exa'
    'firefox'
    'fonts-firacode'
    'fonts-font-awesome'
    'fonts-nerd-font-firacode'
    'fonts-nerd-font-firamono'
    'gcc'
    'git'
    'gnome-calculator'
    'gnome-terminal'
    'gnome-tweaks'
    'gnupg2'
    'htop'
    'libclang-dev'
    'libssl-dev'
    'linux-generic-hwe-22.04'
    'make'
    'nautilus'
    'neofetch'
    'neovim'
    'owncloud-client'
    'p7zip-full'
    'picom'
    'pkg-config'
    'polybar'
    'python3-dev'
    'python3-pynvim'
    'regolith-desktop'
    'regolith-look-gruvbox'
    'seahorse'
    'thunderbird'
    'thunderbird-gnome-support'
    'xsel'
    'xz-utils'
    'yaru-theme-icon'
    'yaru-theme-sound'
    'texlive-full'
  )

  for PACKAGE in "${PACKAGES[@]}"
  do
    if dpkg-query -W --showformat='${Status}' "${PACKAGE}" \
    |& grep "install ok installed" &>/dev/null
    then
      log 'deb' "Package '${PACKAGE}' already installed"
      continue
    fi

    log 'deb' "Installing package '${PACKAGE}' now"

    if ! apt-get install -qq "${PACKAGE}"
    then
      log 'war' "Package '${PACKAGE}' could not be installed"
    fi
  done

  log 'deb' "Removing not needed / wanted packages now"
  apt remove --yes --assume-yes -qq \
    regolith-i3xrocks-config regolith-i3-ftue i3xrocks

  log 'deb' 'Installing Starship prompt'
  sh -c "$(curl -fsSL https://starship.rs/install.sh)" -- --force >/dev/null

  log 'deb' 'Finished installing packages'
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
  
  declare -a CONFIG_FILES
  CONFIG_FILES=(
    '.bashrc'
    '.config/bash/10-setup.sh'
    '.config/bash/80-aliases.sh'
    '.config/bash/90-wrapper.sh'
    '.config/bash/starship.toml'
    '.config/nvim/init.lua'
    '.config/nvim/lua/10-plugins.lua'
    '.config/nvim/lua/60-line.lua'
    '.config/alacritty/alacritty.yml'
    '.config/alacritty/10-general.yml'
    '.config/alacritty/20-font.yml'
    '.config/alacritty/30-colors.yml'
    '.config/alacritty/40-bindings.yml'
    '.config/polybar/launch.sh'
    '.config/polybar/polybar.conf'
    '.config/regolith2/i3/config.d/98-bindings'
    '.config/regolith2/i3/config.d/99-workspaces'
    '.config/regolith2/picom.conf'
    '.config/regolith2/wallpaper.jpg'
    '.config/regolith2/Xresources'
  )

  mkdir -p \
    "${HOME}/.config/alacritty" \
    "${HOME}/.config/bash" \
    "${HOME}/.config/nvim/lua" \
    "${HOME}/.config/polybar" \
    "${HOME}/.config/regolith2/i3/config.d"

  for FILE in "${CONFIG_FILES[@]}"
  do
    curl -qsSfL -o "${HOME}/${FILE}" "${GITHUB_RAW_URL}files/home/${FILE}"
  done
  
  chown "${USER}:${USER}" "${HOME}/.bashrc"
  chown -R "${USER}:${USER}" "${HOME}/.config"
  chmod +x "${HOME}/.config/polybar/launch.sh"

  log 'deb' 'Finished placing configuration files'
}

function main
{
  log 'inf' 'Starting UDS setup process'
  log 'war' \
    'Remember to start this script with sudo' \
    '--preserve-env=USER,HOME - press CTRL-C to abort now'
  sleep 10

  purge_snapd
  add_ppas
  install_packages
  place_configuration_files

  log 'inf' 'Finished UDS setup process'
}

main "${@}"

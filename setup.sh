#! /usr/bin/env bash

# shellcheck disable=SC2317
function __log_unexpected_error() {
  local MESSAGE="unexpected error occurred :: script='${SCRIPT:-${0}}' | function='${1:-none (global)}'"
  MESSAGE+=" | command='${2:-?}' | line = '${3:-?}' | exit-code=${4:-?}"
  log 'err' "${MESSAGE}"
}

# shellcheck disable=SC2034
LOG_LEVEL=${LOG_LEVEL:-inf}
SCRIPT='UDS Setup'
readonly GITHUB_RAW_URL='https://raw.githubusercontent.com/georglauterbach/uds/main/files/'
readonly TMP_CHECK_FILE='/tmp/.uds_running'
export DEBIAN_FRONTEND=noninteractive
export DEBCONF_NONINTERACTIVE_SEEN=true

trap '__log_unexpected_error "${FUNCNAME[0]:-}" "${BASH_COMMAND:-}" "${LINENO:-}" "${?:-}"' ERR
trap 'rm -f ${TMP_CHECK_FILE}' EXIT
set -eE -u -o pipefail
shopt -s inherit_errexit

# shellcheck source=/dev/null
if ! source <(curl -qsSfL https://raw.githubusercontent.com/georglauterbach/libbash/main/modules/log.sh || :)
then
  function log() { echo "[  LOG  ] ${1:-}" ; }
fi

function purge_snapd() {
  command -v snap &>/dev/null || return 0
  log 'inf' "Purging 'snapd'"

  until [[ $(snap list 2>&1 || :) == 'No snaps'*'installed'* ]]
  do
    while read -r SNAP _
    do
      snap remove --purge "${SNAP}" &>/dev/null || :
    done < <(snap list |& tail -n +2 || :)
  done

  apt-get -qq purge snapd gnome-software-plugin-snap
  apt-mark -qq hold snapd
  rm -rf /var/cache/snapd/ "${HOME}/snapd" "${HOME}/snap"

  log 'deb' "Finished purging 'snapd'"
}

function add_ppas() {
  log 'inf' 'Adding PPAs'

  curl -qsSfL -o /etc/apt/sources.list "${GITHUB_RAW_URL}apt/sources.list"
  curl -qsSfL -o /etc/apt/sources.list.d/uds.list "${GITHUB_RAW_URL}apt/uds.list"

  if [[ $(uname -m || :) != 'x86_64' ]]
  then
    log 'deb' 'Fixing sources for ARM64'
    sed -i -E 's|(arch=)amd64|\1arm64|g' /etc/apt/sources.list /etc/apt/sources.list.d/uds.list
  fi

  local GPG_KEY_FILES=(
    'alacritty'
    'brave-browser'
    'git-core'
    'mozillateam'
    'neovim-unstable'
    'regolith'
    'vscode'
  )
  readonly -a GPG_KEY_FILES

  log 'deb' 'Adding GPG files'
  for GPG_FILE in "${GPG_KEY_FILES[@]}"
  do
    curl -qsSfL -o "/etc/apt/trusted.gpg.d/${GPG_FILE}.gpg" "${GITHUB_RAW_URL}apt/gpg/${GPG_FILE}.gpg"
  done

  log 'deb' 'Finished adding PPAs'

  log 'deb' 'Overriding Firefox PPA priority to not use the Snap-package'
  cat >/etc/apt/preferences.d/mozilla-firefox << "EOM"
Package: *
Pin: release o=LP-PPA-mozillateam
Pin-Priority: 1001
EOM
  cat >/etc/apt/apt.conf.d/51unattended-upgrades-firefox << "EOM"
Unattended-Upgrade::Allowed-Origins:: "LP-PPA-mozillateam:${distro_codename}";
EOM

  log 'deb' 'Applying VS Code patch'
  local CODE_SOURCES_FILE='/etc/apt/sources.list.d/vscode.list'
  if [[ -f ${CODE_SOURCES_FILE} ]]
  then
    echo '# deb [arch=amd64,arm64,armhf] http://packages.microsoft.com/repos/code stable main' >"${CODE_SOURCES_FILE}"
  fi

  log 'inf' 'Updating package signatures'
  apt-get -qq update
}

function install_packages() {
  log 'deb' 'Removing update manager'
  apt-get remove -qq update-manager-core

  log 'deb' 'Installing packages now'
  local PACKAGES=(
    'alacritty'
    'bat'
    'btop'
    'build-essential'
    'brave-browser'
    'cmake'
    'code'
    'cups'
    'doas'
    'eog'
    'evince'
    'exa'
    'firefox'
    'fonts-firacode'
    'fonts-font-awesome'
    'fonts-nerd-font-firamono'
    'gcc'
    'git'
    'gnome-calculator'
    'gnome-screenshot'
    'gnome-terminal'
    'gnome-tweaks'
    'gnupg2'
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
    'python3-neovim'
    'regolith-desktop'
    'regolith-look-gruvbox'
    'ripgrep'
    'seahorse'
    'xsel'
    'xz-utils'
    'yaru-theme-icon'
    'yaru-theme-sound'
  )

  if ! apt-get install -qq "${PACKAGES[@]}"
  then
    log 'err' 'Package installation was unsuccessful'
    exit 1
  fi

  log 'deb' 'Removing unwanted packages now'
  apt-get remove -qq regolith-i3xrocks-config regolith-i3-ftue i3xrocks
  apt-get -qq autoremove

  log 'deb' 'Installing Starship prompt'
  curl -qsSfL https://starship.rs/install.sh >install_startship.sh
  sh install_startship.sh --force >/dev/null

  log 'deb' 'Finished installing packages'
}

function place_configuration_files() {
  log 'inf' 'Placing configuration files'

  log 'deb' "Setting up 'doas'"
  echo "permit persist ${USER}" >/etc/doas.conf
  chown -c root:root /etc/doas.conf
  chmod -c 0400 /etc/doas.conf
  if doas -C /etc/doas.conf
  then
    log 'deb' 'doas config looks good'
  else
    log 'war' 'doas config has errors - do not use it immediately'
  fi

  log 'deb' 'Settung of user-specific configuration'
  if ! cd "${HOME}"
  then
    log 'err' 'Could not change directory to home directory - cannot place configuration files'
    exit 1
  fi

  readonly REGOLITH_DIR='.config/regolith2'
  local CONFIG_FILES=(
    '.bashrc'
    '.config/bash/10-setup.sh'
    '.config/bash/30-extra_programs.sh'
    '.config/bash/80-aliases.sh'
    '.config/bash/90-wrapper.sh'
    '.config/bash/ble.conf'
    '.config/bash/starship.toml'
    '.config/nvim/init.lua'
    '.config/alacritty/alacritty.yml'
    '.config/alacritty/10-general.yml'
    '.config/alacritty/20-font.yml'
    '.config/alacritty/30-colors.yml'
    '.config/alacritty/40-bindings.yml'
    '.config/polybar/launch.sh'
    '.config/polybar/polybar.conf'
    "${REGOLITH_DIR}/i3/config.d/98-bindings"
    "${REGOLITH_DIR}/i3/config.d/99-workspaces"
    "${REGOLITH_DIR}/picom.conf"
    "${REGOLITH_DIR}/root"
    "${REGOLITH_DIR}/wallpaper.png"
    "${REGOLITH_DIR}/Xresources"
  )

  for FILE in "${CONFIG_FILES[@]}"
  do
    mkdir -p "$(dirname "${HOME}/${FILE}")"
    curl -qsSfL -o "${HOME}/${FILE}" "${GITHUB_RAW_URL}home/${FILE}"
  done

  readonly REGOLITH_THEME_DIR='/usr/share/regolith-look/gruvbox-material'
  mkdir -p "${REGOLITH_THEME_DIR}"
  cp -r /usr/share/regolith-look/gruvbox/* "${REGOLITH_THEME_DIR}/"
  cp "${HOME}/${REGOLITH_DIR}/root" "${REGOLITH_THEME_DIR}/root"

  chown "${USER}:${USER}" "${HOME}/.bashrc"
  chown -R "${USER}:${USER}" "${HOME}/.config"
  chmod +x "${HOME}/.config/polybar/launch.sh"

  log 'deb' 'Finished placing configuration files'
}

function main() {
  if [[ ${EUID} -ne 0 ]]
  then
    touch "${TMP_CHECK_FILE}"

    log 'deb' 'Running user-specific setup'
    gsettings set org.freedesktop.ibus.panel.emoji hotkey "[]" || :

    log 'deb' 'Starting actual setup'
    # shellcheck disable=SC2312
    sudo env - USER="${USER}" HOME="${HOME}" LOG_LEVEL="${LOG_LEVEL}" bash "$(realpath -eL "${BASH_SOURCE[0]}")"
    exit
  fi

  if [[ ! -f ${TMP_CHECK_FILE} ]]
  then
    log 'err' 'Do not run this script as root yourself'
    exit 1
  fi

  cd /tmp

  log 'inf' 'Starting UDS setup process'
  #purge_snapd
  add_ppas
  install_packages
  place_configuration_files
  log 'inf' 'Finished UDS setup process'
}

main "${@}"

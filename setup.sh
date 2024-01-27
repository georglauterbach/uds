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
# shellcheck disable=SC2312
if ! source <(wget -q -O- https://raw.githubusercontent.com/georglauterbach/libbash/main/modules/log.sh 2>/dev/null)
then
  echo -e "[  \e[91mERROR\e[0m  ] Could not access GitHub - please run 'wget -q -O- https://raw.githubusercontent.com/georglauterbach/libbash/main/modules/log.sh' manually and resolve the errors" >&2
  exit 2
fi

function purge_snapd() {
  command -v snap &>/dev/null || return 0
  log 'inf' "Purging 'snapd'"

  killall snap
  systemctl stop snapd

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

  wget -q -O /etc/apt/sources.list "${GITHUB_RAW_URL}apt/sources.list"

  local PPA_SOURCES_FILES=(
    'alacritty'
    'cryptomator'
    'eza'
    'git-core'
    'mozillateam'
    'neovim-unstable'
    'regolith'
    'vscode'
  )

  local PPA_SOURCE_FILE
  for PPA_SOURCE_FILE in "${PPA_SOURCES_FILES[@]}"
  do
    wget -q -O "/etc/apt/sources.list.d/${PPA_SOURCE_FILE}.sources" "${GITHUB_RAW_URL}apt/${PPA_SOURCE_FILE}.sources"
  done

  if [[ $(uname -m || :) != 'x86_64' ]]
  then
    log 'deb' 'Fixing sources for ARM64'
    for PPA_SOURCE_FILE in /etc/apt/sources.list.d/*
    do
      sed -i -E 's|(Architectures=)amd64|\1arm64|g' "${PPA_SOURCE_FILE}"
    done
  fi

  log 'deb' 'Overriding Firefox PPA priority to not use the Snap-package'
  cat >/etc/apt/preferences.d/mozilla-firefox << "EOM"
Package: *
Pin: release o=LP-PPA-mozillateam
Pin-Priority: 1001
EOM
  cat >/etc/apt/apt.conf.d/51unattended-upgrades-firefox << "EOM"
Unattended-Upgrade::Allowed-Origins:: "LP-PPA-mozillateam:${distro_codename}";
EOM

  log 'deb' 'Finished adding PPAs'
  log 'inf' 'Updating package signatures'
  apt-get -qq update
}

function install_packages() {
  log 'deb' 'Upgrading packages'
  apt-get -qq upgrade
  apt-get -qq dist-upgrade

  log 'deb' 'Removing update manager'
  apt-get -qq remove update-manager-core

  log 'deb' 'Removing no longer required packages'
  apt-get -qq autoremove

  log 'deb' 'Installing packages now'
  local PACKAGES=(
    'alacritty'
    'bash-completion'
    'bat'
    'btop'
    'build-essential'
    'code'
    'cups'
    'doas'
    'eog'
    'evince'
    'eza'
    'firefox'
    'fonts-firacode'
    'fonts-font-awesome'
    'fonts-nerd-font-firamono'
    'git'
    'git-lfs'
    'gnome-calculator'
    'gnome-screenshot'
    'gnome-terminal'
    'gnome-tweaks'
    'gnupg2'
    'nala'
    'nautilus'
    'neofetch'
    'neovim'
    'nextcloud-desktop'
    'p7zip-full'
    'python3-neovim'
    'regolith-desktop'
    'regolith-session-sway'
    'regolith-look-gruvbox'
    'regolith-wm-user-programs'
    'ripgrep'
    'seahorse'
    'xz-utils'
    'yaru-theme-icon'
    'yaru-theme-sound'
  )

  if ! apt-get install -qq "${PACKAGES[@]}"
  then
    log 'err' 'Package installation was unsuccessful'
    exit 1
  fi

  log 'deb' 'Applying VS Code patch'
  local CODE_SOURCES_FILE='/etc/apt/sources.list.d/vscode.list'
  if [[ -f ${CODE_SOURCES_FILE} ]]
  then
    echo '# deb [arch=amd64,arm64,armhf] http://packages.microsoft.com/repos/code stable main' >"${CODE_SOURCES_FILE}"
  fi

  log 'deb' 'Removing unwanted packages now'
  apt-get -qq remove --purge i3xrocks regolith-i3xrocks-config

  log 'deb' 'Removing unwanted packages now'
  apt-get -qq autoremove

  log 'deb' 'Installing Starship prompt'
  wget -q -O install_starship.sh https://starship.rs/install.sh
  sh install_startship.sh --force >/dev/null

  log 'inf' 'To install ble.sh, visit https://github.com/akinomyoga/ble.sh'

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

  readonly REGOLITH_DIR='.config/regolith3'
  local CONFIG_FILES=(
    '.bashrc'
    '.config/alacritty/alacritty.toml'
    '.config/alacritty/10-general.toml'
    '.config/alacritty/20-font.toml'
    '.config/alacritty/30-colors.toml'
    '.config/alacritty/40-bindings.toml'
    '.config/bash/10-setup.sh'
    '.config/bash/30-extra_programs.sh'
    '.config/bash/80-aliases.sh'
    '.config/bash/90-wrapper.sh'
    '.config/bash/ble.conf'
    '.config/bash/starship.toml'
    '.config/nvim/init.lua'
    '.config/polybar/launch.sh'
    '.config/polybar/polybar.conf'
    "${REGOLITH_DIR}/i3/config.d/98-bindings"
    "${REGOLITH_DIR}/i3/config.d/99-workspaces"
    "${REGOLITH_DIR}/looks/gruvbox-material/i3-wm"
    "${REGOLITH_DIR}/looks/gruvbox-material/root"
    "${REGOLITH_DIR}/picom.conf"
    "${REGOLITH_DIR}/wallpaper.png"
    "${REGOLITH_DIR}/Xresources"
  )

  for FILE in "${CONFIG_FILES[@]}"
  do
    mkdir -p "$(dirname "${HOME}/${FILE}")"
    wget -q -O "${HOME}/${FILE}" "${GITHUB_RAW_URL}home/${FILE}"
  done

  sed -i "s|HOME|${HOME}|g" "${HOME}/${REGOLITH_DIR}/Xresources"
  chown "${USER}:${USER}" "${HOME}/.bashrc"
  chown -R "${USER}:${USER}" "${HOME}/.config"

  log 'inf' 'To change the bookmarks in Nautilus, edit ~/.config/user-firs.dirs, ~/.config/gtk-3.0/bookmarks, and /etc/xdg/user-dirs.defaults'
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

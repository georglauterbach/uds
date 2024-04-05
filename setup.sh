#! /usr/bin/env bash

# shellcheck source=/dev/null
if ! source <(wget -q -O- https://raw.githubusercontent.com/georglauterbach/libbash/main/modules/log.sh || :) \
|| [[ $(type -t log || :) != 'function' ]]; then
  echo -e "$(date --iso-8601='seconds' || :)  ERROR  setup.sh  --  Could not access GitHub - please run 'wget -q -O- https://raw.githubusercontent.com/georglauterbach/libbash/main/modules/log.sh' manually and resolve the errors" >&2
  exit 2
fi

# shellcheck disable=SC2317
function __log_unexpected_error() {
  local MESSAGE="unexpected error occurred :: script='${SCRIPT:-${0}}' | function='${1:-none (global)}'"
  MESSAGE+=" | command='${2:-?}' | line = '${3:-?}' | exit-code=${4:-?}"
  log 'error' "${MESSAGE}"
}

# shellcheck disable=SC2034
LOG_LEVEL=${LOG_LEVEL:-trace}
SCRIPT='UDS Setup'
INSTALL_GUI=true
[[ ${*} == *--no-gui* ]] && INSTALL_GUI=false

readonly GITHUB_RAW_URL='https://raw.githubusercontent.com/georglauterbach/uds/main/files/'
readonly TMP_CHECK_FILE='/tmp/.uds_running'

export DEBIAN_FRONTEND=noninteractive
export DEBCONF_NONINTERACTIVE_SEEN=true

trap '__log_unexpected_error "${FUNCNAME[0]:-}" "${BASH_COMMAND:-}" "${LINENO:-}" "${?:-}"' ERR
trap 'rm -f ${TMP_CHECK_FILE}' EXIT
set -eE -u -o pipefail
shopt -s inherit_errexit

function __start() {
  if [[ $(uname -m || :) != 'x86_64' ]]; then
    log 'error' 'arm64 is not supported (APT sources are complicated for arm64)'
    exit 1
  fi

  if [[ ${EUID} -ne 0 ]]; then
    touch "${TMP_CHECK_FILE}"

    if ${INSTALL_GUI}; then
      log 'debug' 'Running user-specific setup'
      gsettings set org.freedesktop.ibus.panel.emoji hotkey "[]" || :
    fi

    log 'debug' 'Acquiring correct permissions'
    # shellcheck disable=SC2312
    sudo env -                 \
      USER="${USER}"           \
      HOME="${HOME}"           \
      LOG_LEVEL="${LOG_LEVEL}" \
      bash "$(realpath -eL "${BASH_SOURCE[0]}")" "${@}"
    exit
  else
    if [[ ! -f ${TMP_CHECK_FILE} ]]; then
      log 'error' 'Do not run this script as root yourself'
      exit 1
    fi

    if ${INSTALL_GUI}; then
      log 'info' 'Configuring GUI'
    else
      log 'info' 'Not configuring GUI'
    fi

    main "${@}"
  fi
}

function main() {
  log 'info' 'Starting UDS setup process'
  #purge_snapd
  add_ppas "${@}"
  install_packages "${@}"
  place_configuration_files "${@}"
  log 'info' 'Finished UDS setup process'
}

function purge_snapd() {
  command -v snap &>/dev/null || return 0
  log 'info' "Purging 'snapd'"

  killall snap
  systemctl stop snapd

  until [[ $(snap list 2>&1 || :) == 'No snaps'*'installed'* ]]; do
    while read -r SNAP _; do
      snap remove --purge "${SNAP}" &>/dev/null || :
    done < <(snap list |& tail -n +2 || :)
  done

  apt-get -qq purge snapd gnome-software-plugin-snap
  apt-mark -qq hold snapd
  rm -rf /var/cache/snapd/ "${HOME}/snapd" "${HOME}/snap"

  log 'debug' "Finished purging 'snapd'"
}

function add_ppas() {
  log 'info' 'Adding PPAs'

  wget -q -O /etc/apt/sources.list "${GITHUB_RAW_URL}apt/sources.list"

  local PPA_SOURCES_FILES=('eza' 'git-core' 'neovim-unstable')
  ${INSTALL_GUI} && PPA_SOURCES_FILES+=('alacritty' 'cryptomator' 'mozillateam' 'regolith' 'vscode')

  local PPA_SOURCE_FILE
  for PPA_SOURCE_FILE in "${PPA_SOURCES_FILES[@]}"; do
    wget -q -O \
      "/etc/apt/sources.list.d/${PPA_SOURCE_FILE}.sources" \
      "${GITHUB_RAW_URL}apt/${PPA_SOURCE_FILE}.sources"
  done

  if ${INSTALL_GUI}; then
    log 'debug' 'Overriding Firefox PPA priority to not use the Snap-package'
    cat >/etc/apt/preferences.d/mozilla-firefox << "EOM"
Package: *
Pin: release o=LP-PPA-mozillateam
Pin-Priority: 1001
EOM
    cat >/etc/apt/apt.conf.d/51unattended-upgrades-firefox << "EOM"
Unattended-Upgrade::Allowed-Origins:: "LP-PPA-mozillateam:${distro_codename}";
EOM
  fi

  log 'debug' 'Finished adding PPAs'
  log 'info' 'Updating package signatures'
  apt-get -qq update
}

function install_packages() {
  log 'debug' 'Upgrading packages'
  apt-get -qq upgrade
  apt-get -qq dist-upgrade

  log 'debug' 'Removing no longer required packages'
  apt-get -qq autoremove

  log 'debug' 'Installing packages'
  local PACKAGES=(
    'bash-completion'
    'bat'
    'btop'
    'build-essential'
    'doas'
    'eza'
    'git'
    'git-lfs'
    'gnupg2'
    'nala'
    'neovim'
    'python3-neovim'
    'ripgrep'
    'xz-utils'
  )

  if ${INSTALL_GUI}; then
    local PACKAGES+=(
      'alacritty'
      'code'
      'cups'
      'eog'
      'evince'
      'firefox'
      'fonts-firacode'
      'fonts-font-awesome'
      'fonts-nerd-font-firamono'
      'gnome-calculator'
      'gnome-screenshot'
      'gnome-terminal'
      'gnome-tweaks'
      'nautilus'
      'neofetch'
      'nextcloud-desktop'
      'p7zip-full'
      'regolith-desktop'
      'regolith-session-sway'
      'regolith-look-gruvbox'
      'regolith-wm-user-programs'
      'seahorse'
      'yaru-theme-icon'
      'yaru-theme-sound'
    )
  fi

  log 'debug' "Packages selected for installation: ${PACKAGES[*]}"
  if ! apt-get install -qq "${PACKAGES[@]}"; then
    log 'error' 'Package installation was unsuccessful'
    exit 1
  fi

  if ${INSTALL_GUI}; then
    log 'debug' 'Applying VS Code patch'
    local CODE_SOURCES_FILE='/etc/apt/sources.list.d/vscode.list'
    if [[ -f ${CODE_SOURCES_FILE} ]]; then
      echo '# deb [arch=amd64] http://packages.microsoft.com/repos/code stable main' >"${CODE_SOURCES_FILE}"
    fi

    log 'debug' 'Removing unwanted packages'
    apt-get -qq remove --purge i3xrocks regolith-i3xrocks-config
  fi

  log 'debug' 'Removing unwanted packages'
  apt-get -qq autoremove

  log 'debug' 'Installing Starship prompt'
  wget -q -O- 'https://starship.rs/install.sh' | sh -s -- --force >/dev/null

  log 'info' 'To install ble.sh, visit https://github.com/akinomyoga/ble.sh'

  log 'debug' 'Finished installing packages'
}

function place_configuration_files() {
  log 'info' 'Placing configuration files'

  log 'debug' "Setting up 'doas'"
  echo "permit persist ${USER}" >/etc/doas.conf
  chown -c root:root /etc/doas.conf
  chmod -c 0400 /etc/doas.conf
  if doas -C /etc/doas.conf; then
    log 'debug' 'doas config looks good'
  else
    log 'warn' 'doas config has errors - do not use it immediately'
  fi

  log 'debug' 'Setting up user-specific configuration'
  if ! cd "${HOME}"; then
    log 'error' 'Could not change directory to home directory - cannot place configuration files'
    exit 1
  fi

  local CONFIG_FILES=(
    '.bashrc'
    '.tmux.conf'
    '.config/bash/10-setup.sh'
    '.config/bash/30-extra_programs.sh'
    '.config/bash/80-aliases.sh'
    '.config/bash/90-wrapper.sh'
    '.config/bash/ble.conf'
    '.config/bash/starship.toml'
    '.config/nvim/init.lua'
  )

  if ${INSTALL_GUI}; then
    readonly REGOLITH_DIR='.config/regolith3'
    CONFIG_FILES+=(
      '.config/alacritty/alacritty.toml'
      '.config/alacritty/10-general.toml'
      '.config/alacritty/20-font.toml'
      '.config/alacritty/30-colors.toml'
      '.config/alacritty/40-bindings.toml'
      '.config/polybar/launch.sh'
      '.config/polybar/polybar.conf'
      "${REGOLITH_DIR}/i3/config.d/98-bindings"
      "${REGOLITH_DIR}/i3/config.d/99-workspaces"
      "${REGOLITH_DIR}/looks/gruvbox-material/i3-wm"
      "${REGOLITH_DIR}/looks/gruvbox-material/root"
      "${REGOLITH_DIR}/picom.conf"
      "${REGOLITH_DIR}/wallpaper.jpg"
      "${REGOLITH_DIR}/Xresources"
    )
  fi

  for FILE in "${CONFIG_FILES[@]}"; do
    mkdir -p "$(dirname "${HOME}/${FILE}")"
    wget -q -O "${HOME}/${FILE}" "${GITHUB_RAW_URL}home/${FILE}"
  done

  if ${INSTALL_GUI}; then
    sed -i "s|HOME|${HOME}|g" "${HOME}/${REGOLITH_DIR}/Xresources"
    log 'info' 'To change the bookmarks in Nautilus, edit ~/.config/user-firs.dirs, ~/.config/gtk-3.0/bookmarks, and /etc/xdg/user-dirs.defaults'
  fi

  chown "${USER}:${USER}" "${HOME}/.bashrc"
  chown -R "${USER}:${USER}" "${HOME}/.config"

  log 'debug' 'Finished placing configuration files'
}

__start "${@}"

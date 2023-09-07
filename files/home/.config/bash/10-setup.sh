#! /usr/bin/env bash

# version       0.3.1
# sourced by    ${HOME}/.bashrc
# task          provides Bash's main setup

function setup_variables() {
  export VISUAL='nvim'
  export EDITOR=${VISUAL}
  export PAGER='less -R'

  export HISTCONTROL='ignoreboth'
  export HISTSIZE=10000
  export HISTFILESIZE=10000

  if command -v batcat &>/dev/null
  then
    export MANPAGER="sh -c 'col -bx | batcat -l man --style=plain --theme=gruvbox-dark'"
    export MANROFFOPT='-c'
    export BAT_PAGER=${PAGER}
  fi
}

function setup_bash_completion() {
  if ! shopt -oq posix
  then
    if [[ -f /usr/share/bash-completion/bash_completion ]]
    then
      # shellcheck source=/dev/null
      source /usr/share/bash-completion/bash_completion
    elif [[ -f /etc/bash_completion ]]
    then
      # shellcheck source=/dev/null
      source /etc/bash_completion
    fi

    if command -v doas &>/dev/null
    then
      complete -cf doas
      alias sudo='doas'
    fi
  fi
}

function setup_miscellaneous() {
  # set specific shell options
  shopt -s histappend checkwinsize globstar autocd

  # more friendly less for non-text input files
  local LP=/usr/bin/lesspipe
  [[ -x ${LP} ]] && eval "$(SHELL=/bin/sh ${LP} || :)"

  # set colors for the `ls` command
  if  [[ ! -x /usr/bin/dircolors ]]   \
  ||  [[ ! -r "${HOME}/.dircolors" ]] \
  ||  ! eval "$(dircolors -b "${HOME}/.dircolors" || :)"
  then
    eval "$(dircolors -b || :)"
  fi
}

function setup_prompt() {
  export PROMPT_DIRTRIM=4

  # continuation shell prompt
  PS2='              > '
  # `set -x` tracing prompt
  PS4='[TRACE] > '

  command -v starship &>/dev/null && return 0

  if [[ -z ${debian_chroot:-} ]] && [[ -r /etc/debian_chroot ]]
  then
    debian_chroot=$(</etc/debian_chroot)
  fi

  if [[ -x /usr/bin/tput ]] && tput setaf 1 &>/dev/null
  then
    PS1='${debian_chroot:+($debian_chroot)}'
    PS1+='\[\033[01;32m\]\u\[\033[00m\]@'
    PS1+='\[\033[01;32m\]\h\[\033[00m\] : '
    PS1+='\[\033[01;34m\]\w\[\033[00m\] \$ '
  else
    PS1=' ${debian_chroot:+($debian_chroot)}'
    PS1+='\u@\h : \w \$ '
  fi
}

setup_variables
setup_bash_completion
setup_miscellaneous
setup_prompt

unset setup_variables
unset setup_bash_completion
unset setup_miscellaneous
unset setup_prompt

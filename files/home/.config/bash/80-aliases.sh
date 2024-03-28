#! /usr/bin/env bash

# version       0.3.0
# sourced by    ${HOME}/.bashrc
# task          configure Bash aliases

alias l='ls'
alias ll='lsa'
alias lsa='ls -a'

alias gcs='git commit'

# this alias is used to make `CTRL + Backspace`
# work in SSH environments
alias ssh='TERM=xterm-256color ssh'

# `EDITOR` is defined in `10-setup.sh`
# shellcheck disable=SC2139,SC2154
alias v="${EDITOR}"
# shellcheck disable=SC2139
alias sv="sudo ${EDITOR}"

alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias ......='cd ../../../../..'
alias .......='cd ../../../../../..'

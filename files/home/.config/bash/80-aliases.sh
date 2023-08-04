#! /usr/bin/env bash

# version       0.2.3
# sourced by    ${HOME}/.bashrc
# task          provides Bash aliases

alias l='ls'
alias ll='lsa'
alias lsa='ls -a'
alias less='less -R'
alias copy='xclip -selection clipboard -in'

alias g='gitui'
alias gb='git branch'
alias gcs='git commit'
alias gf='git fetch --all --tags --prune'
alias gp='git pull'

alias v='nvim'
alias sv='sudo nvim'

alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias ......='cd ../../../../..'
alias .......='cd ../../../../../..'

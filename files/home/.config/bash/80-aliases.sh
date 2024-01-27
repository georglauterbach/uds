#! /usr/bin/env bash

# version       0.2.4
# sourced by    ${HOME}/.bashrc
# task          provides Bash aliases

alias l='ls'
alias ll='lsa'
alias lsa='ls -a'

alias htop='btop'
alias less='batcat --style=plain --paging=always --color=always --theme=gruvbox-dark'

alias g='gitui'
alias gb='git branch'
alias gcs='git commit'
alias gf='git fetch --all --tags --prune'
alias gp='git pull'

alias v='nvim'
alias sv='sudo nvim'

alias k='kubectl'
alias rp='killall polybar && ${HOME}/.config/polybar/launch.sh'

alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias ......='cd ../../../../..'
alias .......='cd ../../../../../..'

#! /bin/bash

# version       0.2.1
# sourced by    ${HOME}/.bashrc
# task          provides Bash aliases

alias l='ls'
alias ll='lsa'
alias lsa='ls -a'
alias less='less -R'
alias copy='xclip -selection clipboard -in'

alias g='gitui'
alias gb='git branch'
alias gcs='git commit -S'
alias gf='git fetch --all --tags --prune'
alias gp='git pull'

alias v='nvim'
alias sv='sudo nvim'

alias k='kubectl'
complete -o default -F __start_kubectl k

alias j='just'
complete -F _just -o bashdefault -o default j

alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias ......='cd ../../../../..'
alias .......='cd ../../../../../..'

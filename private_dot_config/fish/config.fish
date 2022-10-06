if status is-interactive
    load-em
    # Commands to run in interactive sessions can go here
end

eval "$(/opt/homebrew/bin/brew shellenv)"

starship init fish | source #use star-fish prompt
fish_vi_key_bindings #Vim key bindings in shell
kubectl completion fish | source #kubectl autocompletion

#required for yubikey ssh
export GPG_TTY="$(tty)"
export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
gpgconf --launch gpg-agent

set -Ux GOPATH "$HOME/workspace"
set -Ux PATH $PATH:$GOPATH/bin

export EDITOR='code --wait'

set -x AWS_PROFILE ffxblue

alias cz="chezmoi"

alias rmrf="rm -rf"
alias srmrf="sudo rm -rf"
alias dotfiles="ls -a ~"
alias f="fzf"
alias gp="git pull"
alias ga="git add"
alias gcm="git checkout master"
alias gc="git commit -m "
alias gs="git status"
alias gd="git diff"
alias gdm="git diff master"
alias gmc="gitmoji --commit"

alias flyink="fly -t ink"
alias flyinf="fly -t inf"

alias k="kubectl"
alias kx="kubectx"
alias kxd="kubectx blue-development"
alias kxs="kubectx blue-shared"
alias kxp="kubectx blue-production"
alias kxn="kubectx dev-01a"
alias kg='kubectl get'
alias kga='kubectl get all'
alias kgp='kubectl get pods -o wide'
alias kgsv='kubectl get svc'
alias kgd='kubectl get deployment'
alias kgn='kubectl get namespace'
alias kgi='kubectl get ingress'
alias kgs='kubectl get secret'

alias .="code ."
alias v="vim"

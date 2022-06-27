if status is-interactive
    load-em
    # Commands to run in interactive sessions can go here
end

starship init fish | source #use star-fish prompt
kubectl completion fish | source #kubectl autocompletion

#required for yubikey ssh
export GPG_TTY="$(tty)"
export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
gpgconf --launch gpg-agent

export EDITOR='code --wait'

alias rmrf="rm -rf"
alias dotfiles="ls -a ~"
alias f="fzf"

alias flyink="fly -t ink"
alias flyinf="fly -t inf"

alias k="kubectl"
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

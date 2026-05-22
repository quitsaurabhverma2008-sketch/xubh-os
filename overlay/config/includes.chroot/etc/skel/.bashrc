# Xubh OS - .bashrc (exact Kali style, just renamed)
PS1='\[\e[31m\]┌──\[\e[0m\](\[\e[31m\]xubh㉿\h\[\e[0m\])─[\e[31m\]\w\[\e[0m\]\n\[\e[31m\]└─\[\e[0m\]\[\e[31m\]\$\[\e[0m\] '
alias ll='ls -la'
alias la='ls -A'
alias l='ls -CF'
alias cls='clear'
alias xubh-update='sudo apt update && sudo apt full-upgrade -y'
export EDITOR=vim
export TERM=xterm-256color

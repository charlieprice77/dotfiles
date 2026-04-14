export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.local/kitty.app/bin:$PATH"

source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
PROMPT='%n@%m:%~$ '
PROMPT='%F{green}%n@%m%f:%F{blue}%~%f$ '

# enable color support of ls and also add handy aliases
    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
# ~/.bash_aliases, instead of adding them here directly.
alias west-ncs='nrfutil toolchain-manager launch --ncs-version v3.1.0 -- west'
alias west-321='nrfutil toolchain-manager launch --ncs-version v3.2.1 -- west'

#===============================================================================
# ~/.zshrc
#===============================================================================

#===============================================================================
# ssh zsh fix
#===============================================================================

[[ $TERM == "dumb" ]] && unsetopt zle && PS1='$ ' && return


#===============================================================================
# Keep 1000 lines of history within the shell and save it to ~/.zsh_history:
#===============================================================================

HISTSIZE=1000


#===============================================================================
# variables for PS3 prompt
#===============================================================================

newline=$'\n'
yesmaster='Yes Master ? '


#===============================================================================
# source git-prompt.sh
#===============================================================================

source ~/.nix-profile/share/git/contrib/completion/git-prompt.sh


#===============================================================================
# export git status options
#===============================================================================

export GIT_PS1_SHOWDIRTYSTATE=true
export GIT_PS1_SHOWSTASHSTATE=true
export GIT_PS1_SHOWUNTRACKEDFILES=true
export GIT_PS1_SHOWUPSTREAM="auto"
export GIT_PS1_SHOWCOLORHINTS=true


#===============================================================================
# PS3 prompt function
#===============================================================================

function zle-line-init zle-keymap-select {
    PS1="[%n@%M %~]$(__git_ps1 "(%s) ")${newline}${yesmaster}"
    zle reset-prompt
}


#===============================================================================
# run PS3 prompt function
#===============================================================================

zle -N zle-line-init
zle -N zle-keymap-select


#===============================================================================
# set terminal window title to program name
#===============================================================================

case $TERM in
  (*xterm* | xterm-256color)
    function precmd {
      print -Pn "\e]0;%(1j,%j job%(2j|s|); ,)%~\a"
    }
    function preexec {
      printf "\033]0;%s\a" "$1"
    }
  ;;
esac


#===============================================================================
# Fix bugs when switching modes
#===============================================================================

bindkey -v # vi mode
bindkey "^?" backward-delete-char
bindkey "^u" backward-kill-line
bindkey "^a" beginning-of-line
bindkey "^e" end-of-line
bindkey "^k" kill-line


#===============================================================================
# Use modern completion system
#===============================================================================

autoload -Uz compinit
compinit


#===============================================================================
# Set/unset  shell options
#===============================================================================

setopt notify globdots pushdtohome cdablevars autolist
setopt recexact longlistjobs
setopt autoresume histignoredups pushdsilent noclobber
setopt autopushd pushdminus extendedglob rcquotes mailwarning
setopt histignorealldups sharehistory
#setopt auto_cd
cdpath=($HOME)
unsetopt bgnice autoparamslash


#===============================================================================
# Completion Styles
#===============================================================================

# list of completers to use
zstyle ':completion:*::::' completer _expand _complete _ignored _approximate

# allow one error for every three characters typed in approximate completer
zstyle -e ':completion:*:approximate:*' max-errors \
    'reply=( $(( ($#PREFIX+$#SUFFIX)/3 )) numeric )'
    
# insert all expansions for expand completer
zstyle ':completion:*:expand:*' tag-order all-expansions

# formatting and messages
zstyle ':completion:*' verbose yes
zstyle ':completion:*:descriptions' format '%B%d%b'
zstyle ':completion:*:messages' format '%d'
zstyle ':completion:*:warnings' format 'No matches for: %d'
zstyle ':completion:*:corrections' format '%B%d (errors: %e)%b'
zstyle ':completion:*' group-name ''

#eval "$(dircolors -b)"
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' list-colors ''

# match uppercase from lowercase
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

# offer indexes before parameters in subscripts
zstyle ':completion:*:*:-subscript-:*' tag-order indexes parameters

# Filename suffixes to ignore during completion (except after rm command)
zstyle ':completion:*:*:(^rm):*:*files' ignored-patterns '*?.o' '*?.c~' \
    '*?.old' '*?.pro' '.hidden'

# ignore completion functions (until the _ignored completer)
zstyle ':completion:*:functions' ignored-patterns '_*'

# kill - red, green, blue
zstyle ':completion:*:*:kill:*' list-colors '=(#b) #([0-9]#)*( *[a-z])*=22=31=34'

# list optiones colour, white + cyan
zstyle ':completion:*:options' list-colors '=(#b) #(-[a-zA-Z0-9,]#)*(-- *)=36=37'

# zsh autocompletion for sudo and doas
zstyle ":completion:*:(sudo|su|doas):*" command-path /run/wrappers/bin /run/current-system/sw/bin /home/djwilcox/bin

# rehash commands
zstyle ':completion:*' rehash true


#===============================================================================
# highlighting
#===============================================================================

ZSH_HIGHLIGHT_STYLES[suffix-alias]=fg=cyan,underline
ZSH_HIGHLIGHT_STYLES[precommand]=fg=cyan,underline
ZSH_HIGHLIGHT_STYLES[arg0]=fg=cyan
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets pattern)
ZSH_HIGHLIGHT_PATTERNS=('rm -rf *' 'fg=white,bold,bg=red')


#===============================================================================
# script completions
#===============================================================================

#===============================================================================
# audio-switcher
#===============================================================================

_audio-switcher() {
  local curcontext="$curcontext" state line
  typeset -A opt_args

  _arguments -s \
    '-i[Input device]:input device:(mic yeti)' \
    '-o[Output device]:output device:(laptop speakers)' \
    '-h[Show help]'
}

compdef _audio-switcher audio-switcher


#===============================================================================
# backlight
#===============================================================================

_backlight() {
  local curcontext="$curcontext" state line
  typeset -A opt_args

  _arguments -s \
    '-i[Brightness level]:level:(off half on)' \
    '-h[Show help]'
}

compdef _backlight backlight


#===============================================================================
# vpn-netns
#===============================================================================

_vpn-netns() {
  local curcontext="$curcontext" state line
  typeset -A opt_args

  _arguments -s \
    '-c[OpenVPN configuration file]:config file:_files -g "*.ovpn"' \
    '-a[Authentication file]:auth file:_files -g "*.txt"' \
    '-h[Show help]'
}

compdef _vpn-netns vpn-netns


#===============================================================================

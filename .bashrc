# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# cdpath
CDPATH=".:~"

# mpc host and socket
alias mpc='mpc --host="/run/user/1000/mpd/socket"'

# xdg directories
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"

# less
export LESSHISTFILE="${XDG_CONFIG_HOME}/less/history"
export LESSKEY="${XDG_CONFIG_HOME}/less/keys"

# wget
export WGETRC="$XDG_CONFIG_HOME/wget/wgetrc"

# libdvdcss
export DVDCSS_CACHE="${XDG_DATA_HOME}/dvdcss"

# set emacsclient as editor
export ALTERNATE_EDITOR=""
export EDITOR="emacsclient -r -a emacs"
export VISUAL="emacsclient -r -c -a emacs"

# qt5
export QT_QPA_PLATFORMTHEME=qt5ct
#export QT_QPA_PLATFORM=wayland # needed for wayland

# vi mode
export KEYTIMEOUT=1

# mpd host variable for mpc
export MPD_HOST="/run/user/1000/mpd/socket"

# git pager bat with colour
export GIT_PAGER="bat --color=always -p -l rs"

# nix os xdg directories
export XDG_DATA_DIRS="$HOME/.nix-profile/share:$XDG_DATA_DIRS"

# nix-path
export NIX_PATH=$HOME/.nix-defexpr/channels:/nix/var/nix/profiles/per-user/root/channels${NIX_PATH:+:$NIX_PATH}

# nix dont manage shell
if [ -f "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh" ];
    then . "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh";
fi

# nixpkgs
if [ -e /home/djwilcox/.nix-profile/etc/profile.d/nix.sh ];
    then . /home/djwilcox/.nix-profile/etc/profile.d/nix.sh;
fi # added by Nix installer

# NS Fri, 13 May 2011 10:10:27 +0200

[ -z "$PS1" ] && return

###############################################
#
# Basics

PATH=$PATH:/sbin:/usr/sbin:$HOME/bin

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
fi
export EDITOR=vim
export LESS=-i
export INPUTRC=~/.inputrc
###############################################
#
# Some shortcuts

alias ..='cd ..'
alias ...='cd ../..'

alias e=vim
alias r='vim -R'
alias mv='mv -i'
alias cp='cp -i'
alias diff='diff -u'
alias wdiff="wdiff -n -w $'\033[31m' -x $'\033[0m'  -y $'\033[32m' -z $'\033[0m'"
alias ifip4="ifdata -pa"        # Needs moreutils package

export LS_OPTIONS='--color=always'
eval "`dircolors`"
alias ls='ls $LS_OPTIONS'
alias ll='ls $LS_OPTIONS -lha'
alias l='ls $LS_OPTIONS -l'

alias rmwd="cd .. && rm -rf ~-"
cmkdir() { mkdir "$1" && cd "$1"; }

# Integrate colordiff
if [ -x /usr/bin/colordiff ]; then 
    cvsdiff () { cvs diff "$@" | colordiff |less -R; }
    svndiff () { svn diff "$@" | colordiff |less -R; }
    alias cdiff='colordiff -u -x .svn -x CVS'
    vdiff() { cat "$@" | command colordiff | less -R; }
    complete -o default -f -X '!*.@(diff|patch)' vdiff
fi

###############################################
#
# History

# ignoredups and ignorespace
HISTCONTROL=ignoreboth
#HISTTIMEFORMAT='[%a %R] '
HISTTIMEFORMAT='[%a %d.%b %T] '
HISTFILESIZE=10000

# append to the history file, don't overwrite it
shopt -s histappend
# Re-edit failed history expansions.
shopt -s histreedit
shopt -s extglob 
#shopt -s failglob      # XXX breaks tab completion!

###############################################
#
# Prompt

PS1='${debian_chroot:+($debian_chroot)}\[\e[36m\]\u@\h[\W]\$\[\033[00m\] '
unset color_prompt force_color_prompt


###############################################
#
# Terminal window title (with special handling for screen)

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    PROMPT_COMMAND='echo -ne "\033]2;${USER}@${HOSTNAME}: ${PWD/#$HOME/~}\007"'
    ;;
screen|screen-bce) 
    # Hmm. This is still not perfect. E.g. vim sets the window title, and that
    # gets overwritten.
    PROMPT_COMMAND='echo -ne "\033k\033\0134\033]2;${USER}@${HOSTNAME}:"\
        "${PWD/#$HOME/~}\007"'
    ;;
*)
    ;;
esac

###############################################
#
# Utilities

# List subdirectories in the current working directory
lsd() {
    local COL
    if [ -t 1 ]; then COL="|column"; fi
    # This is more efficient than 'ls */', 
    # probably because there's no globbing involved. 
    # It's also faster than find(1). 
    eval 'ls -pL "$@" | sed -n "s,/$,,p"' $COL
}

cdoc() {
    local docdir="/usr/share/doc/$1"
    [ $1 ] || {
        echo "$FUNCNAME: list content of /usr/share/doc/<PACKAGE>"
        return 1
    }
    [ -d "$docdir" ] || {
        echo "$FUNCNAME: '$docdir' not found." >&2
        return 2
    }
    cd "$docdir"
}
complete -F _docdir cdoc

# START completion for ~/bin

# completion for cdoc, ~/bin/lsdoc
_docdir() {
    local cur docdir="/usr/share/doc"
    COMPREPLY=();
    cur=${COMP_WORDS[COMP_CWORD]};
    COMPREPLY=($( compgen -d /usr/share/doc/$cur ));
    COMPREPLY=("${COMPREPLY[@]//\/usr\/share\/doc\//}")    
    return 0
}
[ -x $HOME/bin/lsdoc ] && complete -F _docdir lsdoc

if [ -e /etc/debian_version -a -x $HOME/bin/dbin ]; then 
    # completion for ~/bin/dbin
    _dbin() { 
        # completion routine distilled from _dpkg()
        local cur 
        COMPREPLY=();
        cur=${COMP_WORDS[COMP_CWORD]};
        #_expand || return 0;
        COMPREPLY=($( _comp_dpkg_installed_packages $cur ));
        return 0
    }
    complete -F _dbin dbin
fi

bind "set bell-style none" # no bell

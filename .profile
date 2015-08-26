set -o vi

C00="\[\033[0m\]"       # default color or grey
C01="\[\033[0;30m\]"    # black
C02="\[\033[1;30m\]"    # dark grey (bold)
C03="\[\033[0;31m\]"    # dark red
C04="\[\033[1;31m\]"    # red (bold)
C05="\[\033[0;32m\]"    # dark green
C06="\[\033[1;32m\]"    # green (bold)
C07="\[\033[0;33m\]"    # gold yellow
C08="\[\033[1;33m\]"    # yellow (bold)
C09="\[\033[0;34m\]"    # dark blue
C10="\[\033[1;34m\]"    # blue (bold)
C11="\[\033[0;35m\]"    # dark purple
C12="\[\033[1;35m\]"    # purple (bold)
C13="\[\033[0;36m\]"    # dark seagrean
C14="\[\033[1;36m\]"    # seagreen (bold)
C15="\[\033[0;37m\]"    # grey or regular white
C16="\[\033[1;37m\]"    # white (bold)

if [[ "`id | sed -e 's/.*uid=\([^(]*\).*/\1/'`" -eq 0 ]]; then
  PS1="${C04}[${C10}\u${C13}@${C10}\h${C13}:${C08}\w${C04}]${C13}#${C00} "
else
  PS1="${C04}[${C10}\u${C13}@${C10}\h${C13}:${C08}\w${C04}]${C13}\$${C00} "
fi

PS2="${C05}>${C00} "

################################################

# Figure out what OS we are...
if [[ -f "/etc/redhat-release" ]]; then
	export OSTYPE=RHEL
fi

if [[ -f "/etc/SuSE-release" ]]; then
  export OSTYPE=SLES
fi

if [[ -f "/etc/release" ]]; then
	export OSTYPE=SOLARIS
fi

# Set some pretty aliases...
if [[ $OSTYPE = "RHEL" || $OSTYPE = "SLES" ]]; then
	alias ls='ls --color=auto'
	alias grep='grep --color=auto'
	alias vi='vim'
	eval `dircolors -b`
fi

if [[ $OSTYPE = "SOLARIS" ]]; then
	alias ls='gls --color=auto'
	alias grep='ggrep --color=auto'
	eval `/opt/sfw/bin/gdircolors -b`
fi
                          
# Hate dupes on scrollback and set prompt:
export HISTCONTROL=ignoredups
export PS1 PS2

# To change screen window names:
PROMPT_COMMAND='echo -n -e "\033k`uname -n`\033\\"'

# Because editors will break in screen:
export TERM=xterm-256color
export EDITOR=vi

# To prevent accidental bad stuff:
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

alias dog='zcat -f'
alias vim='vim -X'

# For NIS+ ease:
export NIS_PATH='org_dir.$'

# Extra PATH magic:
export PATH=$PATH:/sbin:/opt/csw/bin

function rgrep {
  what=$1
  where=$2

	# An alternative to grep -R if ggrep is not available on Solaris...
	find $where -exec grep "$what" '{}' \; -print 
}

function release {
	# Tired of typing cat /etc/redhat-release...
	if [[ -f "/etc/redhat-release" ]]; then
		cat /etc/redhat-release
	fi

  if [[ -f "/etc/SuSE-release" ]]; then
    cat /etc/SuSE-release | head -1
  fi

	if [[ -f "/etc/release" ]]; then
		cat /etc/release
	fi
}

function source_if_exists {
  script=$1

  if [[ -f "$script" ]]; then
    . $script
  fi
}

function tmuxify {
  tmux new-session -d -s msavona
  #tmux new-window -t msavona:1 "ssh hosta01"
  #tmux new-window -t msavona:2 "ssh hostb01"
  tmux select-window -t msavona:0
  tmux -2 attach-session -t msavona
}

function extract {
  if [[ -f $1 ]]; then
    case $1 in
      *.tar.bz2)  tar xjf $1      ;;
      *.tar.gz)   tar xzf $1      ;;
      *.bz2)      bunzip2 $1      ;;
      *.rar)      rar x $1        ;;
      *.gz)       gunzip $1       ;;
      *.tar)      tar xf $1       ;;
      *.tbz2)     tar xjf $1      ;;
      *.tgz)      tar xzf $1      ;;
      *.zip)      unzip $1        ;;
      *.Z)        uncompress $1   ;;
      *)          echo "'$1' cannot be extracted via extract()" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}

function total {
  if [ x$1 = x ]; then set `echo 1`; fi
  awk "{total += \$$1} END {print total}"
}

function wiki { dig +short txt $1.wp.dg.cx; }

function pp {
  if [[ "$1" = "" ]]; then echo "Specify something to grep for!"; return; fi
  ps axuw | grep $1 | awk '{ print $2 }' | while read i ; do sudo lsof -nPp $i ; done | grep TCP
}

function randomstr {
  [ "$2" == "0" ] && CHAR="[:alnum:]" || CHAR="[:graph:]"
    cat /dev/urandom | tr -cd "$CHAR" | head -c ${1:-32}
    echo
}

if [[ $- == *i* ]]; then
  [[ "$SSH_AGENT_PID" == "" ]] && eval `ssh-agent -s`
  [ "$SSH_AGENT_PID" ] && (ssh-add -l | grep $USER > /dev/null || { echo "Adding identity to ssh-agent..."; ssh-add; })
fi

# My milkshake brings all the boys the yard...
# (no, I don't know what that means...)
source_if_exists ~/.fsroot/bootstrap/appropriate-environment

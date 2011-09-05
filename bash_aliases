# Various aliases
alias v='vim'
alias ..='cd ..'
alias ...='cd ../..'
alias gcc='gcc -std=c99 -Wall'
alias dir='ls --color=auto --format=vertical'
alias vdir='ls --color=auto --format=long'
alias ll='ls -l'
alias la='ls -A'
alias lla='ll -a'
alias l='ls -CF'
alias lt='ll -tr'
alias lless='ll --color=always | less -R -FX'	# colored scrolling ll
alias sll='sudo ls -l --color=auto'
alias asa='. auto-ssh-agent'
function wp() { dig +short txt "$*.wp.dg.cx"; } # wikipedia commandline
function calc() { echo "$*" | bc -l; } # simple calculator

# simple stopwatch
function stopwatch() {
	log=$(mktemp)
	date
	(time read -s -n 1) >$log 2>&1
	date
	awk '/^real/ { print $2 }' $log
	rm -f $log
}

function open() {
	for i in "$@"; do
		xdg-open "$i"
	done
}
function bak() {
	mv -v "$1"{,~}
}
# NB: vim's syntax highlighting doesn't like nested quotes, but it does work
function unbak() {
	mv -v "$1" "$(dirname "$1")/$(basename "$1" '~')"
}

function say() {
	echo "$*" | festival --tts
}

# smtp port forwarding
alias abfasmail='ssh -Nf -L 2525:smtp.fas.harvard.edu:25 abrody@fas.harvard.edu'

# frequent cd paths
export CDPATH="$CDPATH:/home/andy/documents/Harvard/Senior 2/"
alias cdh='cd "/home/andy/documents/Harvard/Senior 2/"'
alias config="cd '$HOME/documents/Harvard/hcs/config/'"
alias trunk="cd '$HOME/documents/Harvard/hcs/trunk/'"

# aptitude aliases for brevity
alias ainstall='sudo aptitude install'
alias aremove='sudo aptitude remove'
alias asearch='aptitude search'
alias ashow='aptitude show'
alias aupdate='sudo aptitude update && sudo aptitude safe-upgrade'
alias aupgrade='sudo aptitude full-upgrade'
alias awhy='aptitude why'

# git aliases
alias g='git'
alias ga='git add'
alias gb='git branch'
alias gs='git status'
alias gd='git diff'
alias gdc='git diff --cached'
alias gbr='git branch'
alias gco='git checkout'
alias gca='git commit -a'
alias gcam='git commit -a --amend'
alias gst='git stash'
alias gsd='git svn dcommit'
alias gsr='git svn rebase'
alias gbl='git blame'
alias gl='git log'
alias glg='git log --graph'
alias gls='git log --stat'
alias grh='git reset --hard'
alias grs='git reset'
alias gpr='git pull --rebase'
alias gpush='git push'
alias gpull='git pull'
alias gf='git fetch'
alias grb='git rebase'
alias gr='git push origin HEAD:refs/for/master'

# bzr aliases
alias b='bzr'
alias ba='bzr add'
alias bcom='bzr commit -m'
alias bd='bzr cdiff | less -R -FX'
alias bdm='bzr diff --using=meld'
alias bl='bzr log --short -r -7..'
alias bpull='bzr pull'
alias bpush='bzr push'
alias bs='bzr status'
alias bup='bzr update'

# hg aliases
# --color works with Mercurial 1.7.3, not with 1.4.3
#alias hl='hg glog --color=always | less -R'
alias hl='hg glog | less'

# cs161 aliases
alias runddd='ssh -MCX cs161 "(cd ~/cs161/root; ddd --debugger os161-gdb --gdb kernel)"'

# php syntax check
alias phpcheckhere='for file in *.php; do php -l $file; done'
alias phpcheck='find . -name "*.php" -exec php -l {} \;'

ssh-aupdate() {
	if [ -z $1 ]; then
		echo ssh-aupdate HOST
		return 2
	fi
	remotehost=$1
	shift
	echo ssh $remotehost aupdate
	ssh -t $remotehost "sudo aptitude update && sudo aptitude safe-upgrade $*"
}

# grep ignoring .svn folders
grep-svn() {
	find . -path '*/.svn' -prune -o -type f -print0 | xargs -0 -e grep $*
}

# cd && ll
function c () {
	if [ -z "$*" ]; then
		cd && ll --color
	else
		cd "$*" && ll --color
	fi
}

function hcs () {
	if [ -z "$1" ]; then
		host=abrody@hcs.harvard.edu
	elif [[ $1 == *@* ]]; then
		host=$1.hcs.harvard.edu
	else
		host=abrody@$1.hcs.harvard.edu
	fi

	ssh $host
}

# unzip arbitrary archives
function unz() {
	if [ -z "$1" ]; then
		echo $(basename $0) FILE
		return 2
	fi
	if [[ $1 == *.tar.gz || $1 == *.tgz ]]; then
		cmd="tar -xzvf"
	elif [[ $1 == *.tar.bz2 || $1 == *.tar.bz || $1 == *.tbz ]]; then
		cmd="tar -xjvf"
	elif [[ $1 == *.zip ]]; then
		cmd=unzip
	else
		echo "I don't know what to do with \`$1'."
		file "$1"
		return 7
	fi
	echo "+ $cmd \"$1\""
	$cmd "$1"
}

# programming
alias sml='rlwrap sml -Cprint.depth=3000 -Cprint.length=3000'
alias tcl='rlwrap tclsh'
alias math='rlwrap math'
alias py='ipython'
alias pysh='ipython -p sh'

# time long-running jobs
TIMER_LONG_JOBS=30
TIMER_IGNORE_COMMANDS=( ssh vim bash )
function timer_parse_cmd {
  echo $(basename "$1")
}
function timer_start {
  #timer_parse_cmd $BASH_COMMAND
  timer=${timer:-$SECONDS}
}
function timer_stop {
  timer_show=$(($SECONDS - $timer))
  if (( $timer_show > $TIMER_LONG_JOBS )); then
    echo [time: ${timer_show}s]
  fi
  unset timer
}
trap 'timer_start' DEBUG
# add semicolon if $PROMPT_COMMAND already exists
PROMPT_COMMAND="$PROMPT_COMMAND${PROMPT_COMMAND:+;}timer_stop"

# Shell Sink (save bash history to the cloud)
# http://shell-sink.blogspot.com/
#export SHELL_SINK_COMMAND=shellsink-client
#export SHELL_SINK_ID=d7bac19862729300675470595b0d54fa
#export PROMPT_COMMAND="history -a;$SHELL_SINK_COMMAND"
# colon:delimited:tags
#export SHELL_SINK_TAGS=`hostname`

# Less Colors for Man Pages
#export LESS_TERMCAP_mb=$'\E[01;31m'       # begin blinking
#export LESS_TERMCAP_md=$'\E[01;38;5;74m'  # begin bold
#export LESS_TERMCAP_me=$'\E[0m'           # end mode
#export LESS_TERMCAP_se=$'\E[0m'           # end standout-mode
#export LESS_TERMCAP_so=$'\E[38;5;246m'    # begin standout-mode - info box
export LESS_TERMCAP_ue=$'\E[0m'           # end underline
#export LESS_TERMCAP_us=$'\E[04;38;5;146m' # begin underline
export LESS_TERMCAP_us=$'\E[04;38;5;74m' # begin underline

export EDITOR=vim
export DEBFULLNAME='Andy Brody'
export DEBEMAIL='andy@abrody.com'

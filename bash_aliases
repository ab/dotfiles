# Various aliases
alias gcc='gcc -std=c99 -Wall'
alias dir='ls --color=auto --format=vertical'
alias vdir='ls --color=auto --format=long'
alias ll='ls -l'
alias la='ls -A'
alias lla='ll -a'
alias l='ls -CF'
alias lt='ll -tr'
alias lless='ll --color=always | less -R -FX'	# colored scrolling ll
alias open=xdg-open

function bak() {
	mv -v "$1"{,~}
}
# NB: vim's syntax highlighting doesn't like nested quotes, but it does work
function unbak() {
	mv -v "$1" "$(dirname "$1")/$(basename "$1" '~')"
}

# smtp port forwarding
alias abfasmail='ssh -Nf -L 2525:smtp.fas.harvard.edu:25 abrody@fas.harvard.edu'

# frequent cd paths
export HCS_CONFIG_REPO=/var/tmp/abrody/svn-config/
alias cds='cd $HCS_CONFIG_REPO'
alias cdh='cd "/home/andy/documents/Harvard/Junior Summer/"'

# aptitude aliases for brevity
alias ainstall='sudo aptitude install'
alias aremove='sudo aptitude remove'
alias asearch='aptitude search'
alias ashow='aptitude show'
alias aupdate='sudo aptitude update && sudo aptitude safe-upgrade'
alias aupgrade='sudo aptitude full-upgrade'

# git aliases
alias g='git'
alias ga='git add'
alias gb='git branch'
alias gs='git status'
alias gd='git diff'
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
alias grh='git reset --hard'
alias grs='git reset'
alias gpush='git push'
alias gpull='git pull'
alias gf='git fetch'
alias grb='git rebase'

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

# php syntax check
alias phpcheck='for file in *.php; do php -l $file; done'

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
PROMPT_COMMAND="timer_stop;$PROMPT_COMMAND"

# Shell Sink (save bash history to the cloud)
# http://shell-sink.blogspot.com/
#export SHELL_SINK_COMMAND=shellsink-client
#export SHELL_SINK_ID=d7bac19862729300675470595b0d54fa
#export PROMPT_COMMAND="history -a;$SHELL_SINK_COMMAND"
# colon:delimited:tags
#export SHELL_SINK_TAGS=`hostname`

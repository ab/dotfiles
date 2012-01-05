# stripe stuff
PATH="$PATH:$HOME/stripe/pay-server/scripts/bin"
PATH="$PATH:$HOME/stripe/password-vault/bin"
PATH="$PATH:$HOME/stripe/remote-control/bin"
alias aws-stripe-ssh='ssh-add ~/.stripe/aws/stripe-*.pem'
alias aws-apiori-ssh='ssh-add ~/.stripe/aws/apiori/stripe-*.pem'
alias aws-apiori-env='export EC2_PRIVATE_KEY=~/.stripe/aws/apiori/pk-6U6DO743LGPZIGSMNHFK4BM2NZIGBTGU.pem; export EC2_CERT=~/.stripe/aws/apiori/cert-6U6DO743LGPZIGSMNHFK4BM2NZIGBTGU.pem; export EC2_URL=http://ec2.us-west-1.amazonaws.com'

# Make sudo play nice with aliases
alias sudo='sudo '

# Various aliases
alias v='vim'
alias ..='cd ..'
alias ...='cd ../..'
alias gcc='gcc -std=c99 -Wall'
alias dir='ls --color=auto --format=vertical'
alias vdir='ls --color=auto --format=long'
alias ll='ls -lh'
alias la='ls -la'
alias lad='ls -lad'
alias lls='ll -Shr'
alias llt='ll -tr'
alias l='ls -C'
alias lless='ll --color=always | less -R -FX'	# colored scrolling ll
alias sll='sudo ls -l --color=auto'
alias asa='. auto-ssh-agent'
alias private='HISTFILE=/dev/null'
alias mtime='stat --format=%y'
alias ips='ip -o -f inet addr show scope global | cut -d" " -f 2,7 | cut -d/ -f1'
alias ds='dig +short'
function wp() { dig +short txt "$*.wp.dg.cx"; } # wikipedia commandline
function calc() { echo "$*" | bc -l; } # simple calculator
alias findf='find . -name '
function search() { grep -rIn --color "$@" * ; }
function isearch() { grep -rIni --color "$@" * ; }
alias wgetn='wget -O /dev/null'
function whichedit() { $EDITOR $(which $*) ; }

function swap() {
	if [ $# -lt 2 ]; then
		echo>&2 "swap file1 file2"
		return 1
	fi
	set -e
	mv -i "$2" "$1.$$"
	mv -i "$1" "$2"
	mv -i "$1.$$" "$1"
}

function decrypt() {
    stripped="${1%.gpg}"
    if [ "$1" = "$stripped" ]; then
        echo>&2 "decrypt: $1 does not appear to end with .gpg"
        return 1
    fi
    echo>&2 "+ gpg -o '$stripped' -d '$1'"
    gpg -o "$stripped" -d "$1"
}

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

# NB: vim's syntax highlighting doesn't like nested quotes, but it does work
function cbak() {
	cp -avi "$(dirname "$1")/$(basename "$1")"{,~}
}
function sbak() {
	sudo cp -avi "$(dirname "$1")/$(basename "$1")"{,~}
}
function bak() {
	mv -v "$(dirname "$1")/$(basename "$1")"{,~}
}
function unbak() {
	mv -v "$1" "$(dirname "$1")/$(basename "$1" '~')"
}

function say() {
	echo "$*" | festival --tts
}

# smtp port forwarding
alias abfasmail='ssh -Nf -L 2525:smtp.fas.harvard.edu:25 abrody@fas.harvard.edu'

# frequent cd paths
export CDPATH="$CDPATH:/home/andy/stripe/"
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
alias gss='git status --short'
alias gsh='git show'
alias gd='git diff'
alias gdc='git diff --cached'
alias gdw='git diff --word-diff' # git 1.7.2+
alias gbr='git branch'
alias gco='git checkout'
alias gcoh='git checkout HEAD'
alias gc='git commit'
alias gca='git commit -a'
alias gcam='git commit -a --amend'
alias gst='git stash'
alias gsd='git svn dcommit'
alias gsr='git svn rebase'
alias gsa='git submodule add'
alias gsi='git submodule init'
alias gsf='git submodule foreach'
alias gsu='git submodule update'
alias gbl='git blame'
alias gl='git log'
alias glg='git log --graph --decorate'
alias gls='git log --stat'
alias glt='git log --oneline --decorate'

alias grH='git reset HEAD'
alias grh='git reset --hard'
alias grs='git reset'
alias grm='git ls-files -z --deleted | xargs -0 git rm'
alias gpl='git pull'
alias gplr='git pull --rebase'
alias gps='git push'
alias gpush='git push'
alias gpull='git pull'
alias gfetch='git fetch'
alias grb='git rebase'
alias gr='git push origin HEAD:refs/for/master'
gf() { git show --pretty='format:' --name-only $* | grep -v '^$' | uniq | sed -e "s#^#$(git rev-parse --show-toplevel)/#" ; }
ge() { $EDITOR $(gf "$*") ; }

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
	elif [[ $1 == *.tar ]]; then
		cmd="tar -xvf"
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

# virtualenv activate
alias activate="source env/bin/activate"

# time long-running jobs
TIMER_LONG_JOBS=30
TIMER_IGNORE_COMMANDS=( ssh vim bash )
function _timer_parse_cmd {
    echo $(basename "$1")
}
function _timer_start {
    #_timer_parse_cmd $BASH_COMMAND
    timer=${timer:-$SECONDS}
}
function _timer_stop {
    timer_show=$(($SECONDS - $timer))
    if (( $timer_show > $TIMER_LONG_JOBS )); then
        echo "[time: ${timer_show}s] "
    fi
    unset timer
}
trap '_timer_start' DEBUG
# add semicolon if $PROMPT_COMMAND already exists
export PROMPT_COMMAND="_timer_stop${PROMPT_COMMAND:+;}$PROMPT_COMMAND"

# print exit status if nonzero (unless running in a script)
#trap '_EXIT_CODE=$?; [ -z "$BASH_SOURCE" ] && echo -e "\033[01;31m[$_EXIT_CODE]\033[m"; unset _EXIT_CODE' ERR
#trap '_EXIT_CODE=$?; [ -z "$BASH_SOURCE" ] && echo -e "[exit: $_EXIT_CODE]"; unset _EXIT_CODE' ERR
trap '_EXIT_CODE=$?; [ -z "$BASH_SOURCE" ] && echo -e "\033[1;31m$_EXIT_CODE\033[m"; unset _EXIT_CODE' ERR

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

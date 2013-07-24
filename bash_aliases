add_to_path() {
    [ -d "$1" ] && export PATH="$PATH:$1"
}

# stripe stuff
add_to_path ~/stripe/apiori/space-commander/bin
add_to_path ~/stripe/password-vault/bin
add_to_path ~/stripe/remote-control/bin
add_to_path ~/stripe/pay-server/scripts/bin
add_to_path ~/stripe/henson/bin
add_to_path ~/.gem/ruby/1.9.1/bin
add_to_path ~/.gem/ruby/1.8/bin
export REMOTECONTROL_NO_BUNDLER=1

ruby18-env() {
    local ORIG_PATH="$PATH"
    local ORIG_IFS="$IFS"
    IFS=':'
    PATH=''

    for item in $ORIG_PATH; do
        if [[ $item == */ruby/* ]]; then
            continue
        fi
        PATH="$PATH$item:"
    done
    IFS="$ORIG_IFS"

    export AB_RUBY=1.8
    export PATH="$PATH$HOME/.gem/ruby/$AB_RUBY/bin"

    export ORIG_PS1="${ORIG_PS1:-$PS1}"
    export PS1="\[\e[33m\](ruby $AB_RUBY)\[\e[m\] $ORIG_PS1"
}

alias aws-stripe-ssh='ssh-add ~/.stripe/aws/stripe-*.pem'
alias aws-stripe-env='export EC2_PRIVATE_KEY=~/.stripe/aws/pk-BOINZURLRNL7FT377OK4NBV2ZCVW6MTW.pem; export EC2_CERT=~/.stripe/aws/cert-BOINZURLRNL7FT377OK4NBV2ZCVW6MTW.pem; export EC2_URL=http://ec2.us-west-1.amazonaws.com'
alias aws-apiori-ssh='ssh-add ~/.apiori/aws/apiori-2.pem'
alias aws-apiori-env='export EC2_PRIVATE_KEY=~/.apiori/aws/pk-S5HDM3FKQGM7NZNDVMTDXCUX653UARYY.pem; export EC2_CERT=~/.apiori/aws/cert-S5HDM3FKQGM7NZNDVMTDXCUX653UARYY.pem; export EC2_URL=http://ec2.us-west-1.amazonaws.com'
alias aws-secondary-ssh='ssh-add ~/.ssh/stripe-ctf-key'
alias aws-secondary-env='export EC2_PRIVATE_KEY=~/.stripe/personal/secondary/pk-QSDHLWH4BI75ZRZSHM2LLIKPJ2HXYU6D.pem; export EC2_CERT=~/.stripe/personal/secondary/cert-QSDHLWH4BI75ZRZSHM2LLIKPJ2HXYU6D.pem; export EC2_URL=http://ec2.us-east-1.amazonaws.com'
alias aws-ctf-ssh='ssh-add ~/.stripe/aws/ssh/ctf.stri.pe'
alias aws-ctf-env='export EC2_PRIVATE_KEY=~/.stripe/personal/secondary/pk-QSDHLWH4BI75ZRZSHM2LLIKPJ2HXYU6D.pem; export EC2_CERT=~/.stripe/personal/secondary/cert-QSDHLWH4BI75ZRZSHM2LLIKPJ2HXYU6D.pem; export EC2_URL=http://ec2.us-west-1.amazonaws.com'

stripe-clone() {
    run git clone git@github.com:stripe-internal/"$1".git
}
alias sclone=stripe-clone

set_var_verbose() {
    local var="$1"
    local val="$2"

    echo >&2 "$var=$val"
    export "$var=$val"
}

set_var_gpg() {
    local var="$1"
    local file="$2"

    echo >&2 "Setting $var from \`$file'"
    val="$(gpg --batch -qd "$file")" || return 1
    export "$var=$val"
}

aws-env() {
    local domain="$1"
    local region="$2"

    local access_key_file secret_key_file

    case "$domain" in
        apiori|apiori.com)
            access_key_file=~/.apiori/personal/aws_access_key_id.gpg
            secret_key_file=~/.apiori/personal/aws_secret_key.gpg
            ;;
        stripe|stripe.com)
            access_key_file=~/.stripe/personal/aws_access_key_id.gpg
            secret_key_file=~/.stripe/personal/aws_secret_key.gpg
            ;;
        stri.pe|stripe-ctf.com|secondary)
            access_key_file=~/.stripe/personal/secondary/aws_access_key_id.gpg
            secret_key_file=~/.stripe/personal/secondary/aws_secret_key.gpg
            ;;
        *)
            echo>&2 "Unknown domain: '$domain'"
            echo>&2 "Try one of apiori, stripe, or secondary"
            return 2
            ;;
    esac

    if [ -z "$region" ]; then
        region=us-west-1
    fi

    # handle region nicknames
    case "$region" in
        east)
            region="us-east-1"
            ;;
        west)
            region="us-west-1"
            ;;
        eu|europe)
            region="eu-west-1"
            ;;
        au|australia)
            region="ap-southeast-2"
            ;;
    esac

    case "$region" in
        eu-west-1      | \
        sa-east-1      | \
        us-east-1      | \
        ap-northeast-1 | \
        us-west-2      | \
        us-west-1      | \
        ap-southeast-1 | \
        ap-southeast-2 )
            true
            ;;
        *)
            echo>&2 "Unknown EC2 region: $region"
            return 3
            ;;
    esac

    set_var_gpg AWS_ACCESS_KEY "$access_key_file" || return 1
    set_var_gpg AWS_SECRET_KEY "$secret_key_file" || return 1
    set_var_verbose EC2_URL "http://ec2.$region.amazonaws.com"
}

alias cdp="cd /etc/puppet"
pgit() {
    sudo bash -c '
        . /usr/stripe/bin/git-author.sh "$SUDO_USER"
        set -x
        cd /etc/puppet
        git "$@"
        ' -- "$@"
}
pgc() {
    sudo bash -c '
        . /usr/stripe/bin/git-author.sh "$SUDO_USER"
        set -x
        cd /etc/puppet
        git commit "$@"
        ' -- "$@"
}

alias cur-apiori='curl -sS https://api.stripe.com/healthcheck | cut -f1,2 -d.'
alias cur-fe='curl -sS https://stripe.com/healthcheck/fe | cut -f1 -d.'
alias cur-hal='curl -sS http://stripe.com/healthcheck/haproxy | cut -f1 -d.'

_c() {
    local col=$1
    shift
    awk "{print \$$col}" "$@"
}

alias gpgk="gpg --no-default-keyring --keyring"
alias gpgk.="gpg --no-default-keyring --keyring ./pubring.gpg --secret-keyring ./secring.gpg"
alias gpg-stripe="gpg --keyserver pgp.stripe.com"

# Make sudo play nice with aliases
alias sudo='sudo '

# Various aliases
alias v='vim'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias cdg='cd "$(git rev-parse --show-toplevel)"'
alias gcc='gcc -std=c99 -Wall'
alias dir='ls --color=auto --format=vertical'
alias vdir='ls --color=auto --format=long'
alias ll='ls -lh'
alias la='ls -la'
alias lad='ls -lad'
alias lla='ll -a'
alias lls='ll -Shr'
alias llt='ll -tr'
alias l='ls -C'
alias lless='ll --color=always | less -R -FX'    # colored scrolling ll
alias lesssn='less -Sn'
alias lessen='less -Sn'
alias lessn='less -n'
alias sll='sudo ls -l --color=auto'
alias mvi='mv -iv'
alias asa='. auto-ssh-agent'
alias mtime='stat --format=%y'
alias ips='ip -o addr show scope global | grep inet | cut -d" " -f 2,7 | cut -d/ -f1'
alias ds='dig +short'
alias clip='xclip -selection clipboard'
function wp() { dig +short txt "$*.wp.dg.cx"; } # wikipedia commandline
function calc() { echo "$*" | bc -l; } # simple calculator
alias findf='find . -name '
function search() { grep -rIn --color "$@" * ; }
function isearch() { grep -rIni --color "$@" * ; }
alias wgetn='wget -O /dev/null'
alias wget-='wget -O -'
function whichedit() { $EDITOR $(which "$@") ; }
function vimwhich() { vim $(which "$@") ; }
alias du-fs='du -xh --max-depth 1'
alias syslog='less +F /var/log/syslog'

function private() {
    export HISTFILE=/dev/null
    export ORIG_PS1="${ORIG_PS1:-$PS1}"
    export PS1="\[\e[30m\e[47m\]${ORIG_PS1%% }\[\e[m\] "
}

# just for fun
alias donotwant='rm -v'
alias DONOTWANT='rm -rfv'

# ruby aliases
alias gemi='gem install --user-install'

splice_out() {
    (set -eu
    local file="$1"
    shift
    new_content="$(run grep -v "$@" "$file")"
    run sponge "$file" <<< "$new_content"
    )
}

function ssh-steal-agent() {
    if [ $# -lt 1 ]; then
        cat >&2 <<EOM
usage: ssh-steal-agent PID

Take the SSH_AUTH_SOCK and SSH_AGENT_PID variables from another process.
EOM
        return 1
    fi
    local pid="$1"
    while IFS= read -r -d '' env; do
        local var="$(echo "$env" | cut -d '=' -f 1)"
        local val="$(echo "$env" | cut -d '=' -f 2-)"

        if [ "$var" = "SSH_AUTH_SOCK" ]; then
            echo "+ SSH_AUTH_SOCK=$val"
            export SSH_AUTH_SOCK="$val"
        elif [ "$var" = "SSH_AGENT_PID" ]; then
            echo "+ SSH_AGENT_PID=$val"
            export SSH_AGENT_PID="$val"
        fi
    done < "/proc/$pid/environ"
}

function swap() {
    if [ $# -lt 2 ]; then
        echo>&2 "swap file1 file2"
        return 1
    fi
    set -e
    mv -iv "$2" "$1.$$"
    mv -iv "$1" "$2"
    mv -iv "$1.$$" "$1"
}

# sort files in place
function sort_() {
    declare -a options=()
    while [[ $# -gt 0 && $1 == -* ]]; do
        if [ "$1" = "--" ]; then
            break
        fi

        options+=("$1")
        shift
    done

    if [ $# -eq 0 ]; then
        echo >&2 "usage: sort_ [options] FILE..."
        echo >&2 ""
        echo >&2 "Sort each FILE in place."
        return 1
    fi

    for file in "$@"; do
        run sort "${options[@]}" -o "$file" -- "$file"
    done
}

function decrypt() {
    local stripped="${1%.gpg}"
    if [ "$1" = "$stripped" ]; then
        echo>&2 "decrypt: $1 does not appear to end with .gpg"
        return 1
    fi
    echo>&2 "+ gpg -o '$stripped' -d '$1'"
    gpg -o "$stripped" -d "$1"
}

# simple stopwatch
function stopwatch() {
    local log=$(mktemp)
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

# like set -x
function run() {
    echo>&2 "+ $*"
    "$@"
}

# NB: vim's syntax highlighting doesn't like nested quotes, but it does work
function cbak() {
    [ -n "$1" ] || { echo >&2 "cp: missing file operand" ; return 1 ; }
    cp -avi "$(dirname "$1")/$(basename "$1")"{,~}
}
function sbak() {
    [ -n "$1" ] || { echo >&2 "cp: missing file operand" ; return 1 ; }
    sudo cp -avi "$(dirname "$1")/$(basename "$1")"{,~}
}
function bak() {
    [ -n "$1" ] || { echo >&2 "mv: missing file operand" ; return 1 ; }
    mv -v "$(dirname "$1")/$(basename "$1")"{,~}
}
function unbak() {
    [ -n "$1" ] || { echo >&2 "mv: missing file operand" ; return 1 ; }
    mv -v "$1" "$(dirname "$1")/$(basename "$1" '~')"
}

function say() {
    echo "$*" | festival --tts
}

# unmount all encfs partitions
function encfs-umount-all() {
    grep ^encfs /etc/mtab | cut -d' ' -f 2 | while read mount; do
        run fusermount -u "$mount"
    done
}

# frequent cd paths
export CDPATH="$CDPATH:/home/andy/stripe/"
export CDPATH="$CDPATH:/home/andy/stripe/apiori/"
alias config="cd '$HOME/documents/Harvard/hcs/config/'"
alias trunk="cd '$HOME/documents/Harvard/hcs/trunk/'"

# aptitude aliases for brevity
#alias ainstall='sudo aptitude install'
alias aremove='sudo aptitude remove'
alias asearch='aptitude search'
alias ashow='aptitude show'
alias aupdate='sudo aptitude update && sudo aptitude safe-upgrade'
alias aupgrade='sudo aptitude full-upgrade'
alias awhy='aptitude why'

ainstall() {
    local log="$HOME/install.log"
    for name in "$@"; do
        if ! awk '{print $NF}' "$log" | grep -x "$name" >/dev/null; then
            date "+%F %R	$name" >> "$log"
        fi
    done
    sudo aptitude install "$@"
}

# git aliases
alias g='git'
alias ga='git add'
alias gb='git branch'
alias gg='git grep'
alias ggp='git --no-pager grep'
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
alias gcm='git commit --amend'
alias gcl='git clone'
alias gh='git help'
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
alias glgs='git log "--pretty=format:%C(yellow)%h%C(bold blue)%d%Creset %ar %Cgreen%an%Creset %s" --graph --decorate'
alias gls='git log --stat --show-signature'
alias glt='git log --oneline --decorate'

alias gr='git reset'
alias grH='git reset HEAD'
alias grh='git reset --hard'
alias grm='git ls-files -z --deleted | xargs -0 git rm'
alias grv='git remote -v'
alias gru='git remote update'
alias gpl='git pull --ff-only'
alias gplr='git pull --rebase'
alias gps='git push'
alias gpss='git push stripe master && git push'
alias gpsr='git pull --rebase && git push'
alias gpush='git push'
alias gpull='git pull'
alias gfetch='git fetch'
alias gfe='git fetch'
alias gfep='git fetch -p'
alias grb='git rebase'
alias grvb='git push origin HEAD:refs/for/master'
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
    local remotehost=$1
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

# Silly function to echo arguments on stdout
# It's mostly useful for testing bash arrays and shell expansion and such.
function args() {
    echo >&2 "argc: $#"
    while [ $# -gt 0 ]; do
        echo "$1"
        shift
    done
}

# unzip arbitrary archives
function unz() {
    if [ $# -lt 1 ]; then
        echo unz FILE
        return 2
    fi
    if [[ $1 == *.tar.gz || $1 == *.tgz ]]; then
        cmd="tar -xzvf"
    elif [[ $1 == *.tar.bz2 || $1 == *.tar.bz || $1 == *.tbz ]]; then
        cmd="tar -xjvf"
    elif [[ $1 == *.tar.xz || $1 == *.txz ]]; then
        cmd="tar -xJvf"
    elif [[ $1 == *.zip ]]; then
        cmd=unzip
    elif [[ $1 == *.tar ]]; then
        cmd="tar -xvf"
    elif [[ $1 == *.7z ]]; then
        cmd="7zr x"
    else
        echo "I don't know what to do with \`$1'."
        file "$1"
        return 7
    fi
    echo "+ $cmd \"$1\""
    $cmd "$1"
}

# make a tarball
function tarball() {
    if [ $# -lt 1 ]; then
        echo>&2 tarball DIRECTORY
        return 2
    fi
    local parent="$(dirname "$1")"
    local dir="$(basename "$1")"
    run tar -czvf "$dir.tgz" -C "$parent" "$dir/"
}

# programming
alias sml='rlwrap sml -Cprint.depth=3000 -Cprint.length=3000'
alias tcl='rlwrap tclsh'
alias math='rlwrap math'
alias py='ipython'
alias pysh='ipython -p sh'

_pyval() {
    local python_cmd="print $@"
    python -c "${python_cmd}"

    case "$shopts" in
        *noglob*) ;;
        *) set +f;;
    esac

    unset shopts
}

alias p='shopts="$SHELLOPTS"; set -f; _pyval'

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
    [ -z "$timer" ] && return

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

# Preserve history indefinitely
export HISTFILESIZE=
export HISTSIZE=

if [ -d "$HOME/.rbenv/bin" ]; then
   export PATH="$PATH:$HOME/.rbenv/bin"
   if [ -x "$HOME/.rbenv/bin/rbenv" ]; then
       eval "$(rbenv init -)"
   fi
fi

# vim: ft=sh

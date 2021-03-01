#!/bin/bash
# ^ clue vim in on the fact that this bash
# shellcheck disable=SC2230

add_to_path() {
    [ -d "$1" ] && export PATH="$PATH:$1"
}

# stripe stuff
add_to_path ~/stripe/space-commander/bin
add_to_path ~/stripe/password-vault/bin
export SPACECOMMANDER_LOG_LEVEL=0
export SPACECOMMANDER_NO_SSH_COMMANDLINE=1
export SC_USER=andy

case $HOSTNAME in
    endor|endor.agb.me)
        export PASSWORD_VAULT_SELECTION=clipboard
        export ABPW_SELECTION=clipboard
        ;;
esac

gsutil-md5() {
    file="$1"

    local output md5

    output="$(run gsutil ls -L "$file")" || return 1
    md5="$(grep -m 1 -F 'Hash (md5):' <<< "$output" | awk '{ print $NF }' | \
           base64 -d | xxd -p)"
    echo "$md5  $file"
}
gsutil-link() {
    local url duration p12_file privkeys

    if [ $# -ge 1 ]; then
        url="$1"
    else
        echo 'usage: gsutil-link URL [DURATION [P12_FILE]]'
        return 1
    fi

    if [ $# -ge 2 ]; then
        duration="$2"
    else
        echo 'Using 1 day validity by default'
        duration="1d"
    fi

    if [ $# -ge 3 ]; then
        p12_file="$3"
    else
        privkeys="$(run ls -1 -- ~/Private/gce/Main-*.p12)"
        p12_file="$(head -1 <<< "$privkeys")"
        echo 'Keystore password is probably not a secret'
    fi

    run gsutil signurl -d "$duration" "$p12_file" "$url"
}

github-clone() {
    case $# in
        0)
            echo >&2 "usage: github-clone org/repo"
            echo >&2 "usage: github-clone org repo"
            return 1
            ;;
        1)
            run git clone git@github.com:"$1".git
            ;;
        *)
            run git clone git@github.com:"$1/$2".git
            ;;
    esac
}

clone-chalk() {
    run git clone git@github.com:stripe/"$1".git && \
        (cd "$1" && git-config-email stripe)
}
clone-uscis() {
    (
    set -eu
    run git clone "git@$USCIS_GIT_HOST:USCIS/$1.git" && \
        (cd "$1" && git-config-email uscis)
    )
}
clone-18f() {
    (
    set -eu
    run git clone "git@github.com:18F/$1.git" && \
        (cd "$1" && git-config-email gsa)
    )
}

git-config-email() {
    local email

    case "$1" in
        stripe) email=andy@stripe.com ;;
        uscis)  email="$USCIS_EMAIL" ;;
        gsa)    email="$GSA_EMAIL" ;;
        *)
            echo >&2 "git-config-email: No email for '$1'"
            return 1
            ;;
    esac

    run git config --local user.email "$email"
}

# proxy stuff
enproxy() {
    if [ -z "${ENPROXY_HOST-}" ]; then
        echo >&2 "enproxy: please set ENPROXY_HOST"
        return 1
    fi
    local proto
    proto="${ENPROXY_PROTO-http}"
    set_var_verbose http_proxy "$proto://$ENPROXY_HOST:${ENPROXY_PORT-80}"
    set_var_verbose https_proxy "$proto://$ENPROXY_HOST:${ENPROXY_PORT-80}"
    if [ -n "${ENPROXY_NO_PROXY-}" ]; then
        set_var_verbose no_proxy "$ENPROXY_NO_PROXY"
    fi
    if [ -n "${ENPROXY_USER_AGENT-}" ]; then
        set_var_verbose HTTP_USER_AGENT "$ENPROXY_USER_AGENT"
    fi

    localproxy-enable
}
deproxy() {
    echo >&2 "+ unset -v http_proxy https_proxy noproxy HTTP_USER_AGENT"
    unset -v http_proxy https_proxy noproxy HTTP_USER_AGENT

    localproxy-disable
}
auto-enproxy() {
    if [ -z "${ENPROXY_HOST-}" ]; then
        return;
    fi

    if ping -c 2 -i 0.25 -W 300 "$ENPROXY_HOST" >/dev/null; then
        enproxy
    elif [ -n "${http_proxy-}${https_proxy-}" ]; then
        deproxy
    else
        localproxy-disable
    fi
}

set_var_verbose() {
    local var="$1"
    local val="$2"

    echo >&2 "$var=$val"
    export "$var=$val"
}

set_var_cat() {
    local var="$1"
    local file="$2"

    echo >&2 "Setting $var from \`$file'"
    val="$(cat "$file")" || return 1
    export "$var=$val"
}

set_var_gpg() {
    local var="$1"
    local file="$2"

    echo >&2 "Setting $var from \`$file'"
    val="$(gpg --batch -qd "$file")" || return 1
    export "$var=$val"
}

# AWS env stuff. You should probably use AWS profiles instead of this.
aws-env() {
    local name="$1"
    local region="${2:-}"

    local access_key_file secret_key_file

    case "$name" in
        login|login.gov|identity)
            access_key_file=~/.aws/personal/login.gov/aws_access_key_id.txt
            secret_key_file=~/.aws/personal/login.gov/aws_secret_key.gpg
            region="${region:-us-west-2}"
            ;;
        *)
            echo>&2 "Unknown name: '$name'"
            return 2
            ;;
    esac

    region="${region:-us-east-1}"

    # handle region nicknames
    case "$region" in
        east|virginia|va)
            region="us-east-1"
            ;;
        oh|ohio)
            region="us-east-2"
            ;;
        west|california|ca)
            region="us-west-1"
            ;;
        nw|northwest|oregon|or)
            region="us-west-2"
            ;;
        eu|europe|ireland|dublin|ie)
            region="eu-west-1"
            ;;
        gov|govcloud)
            region="us-gov-west-1"
            ;;
        au|australia)
            region="ap-southeast-2"
            ;;
    esac

    case "$region" in
        ap-northeast-1 | \
        ap-northeast-2 | \
        ap-south-1 | \
        ap-southeast-1 | \
        ap-southeast-2 | \
        ca-central-1 | \
        eu-central-1 | \
        eu-west-1 | \
        eu-west-2 | \
        sa-east-1 | \
        us-east-1 | \
        us-east-2 | \
        us-west-1 | \
        us-west-2)
            export AWS_DEFAULT_REGION="$region"
            ;;
        *)
            echo>&2 "Unknown EC2 region: $region"
            return 3
            ;;
    esac

    set_var_cat AWS_ACCESS_KEY "$access_key_file" || return 1
    export AWS_ACCESS_KEY_ID="$AWS_ACCESS_KEY"
    set_var_gpg AWS_SECRET_KEY "$secret_key_file" || return 1
    export AWS_SECRET_ACCESS_KEY="$AWS_SECRET_KEY"
    set_var_verbose AWS_DEFAULT_REGION "$region"
}

alias cur-apiori='curl -sS https://api.stripe.com/healthcheck | cut -f1,2 -d.'
alias cur-fe='curl -sS https://stripe.com/healthcheck/fe | cut -f1,2 -d.'
alias cur-hal='curl -sS http://stripe.com/healthcheck/haproxy | cut -f1,2 -d.'

_c() {
    local col=$1
    shift
    awk "{print \$$col}" "$@"
}

# USE GPG2
if [ "$(type -t gpg2)" = "file" ]; then
    alias gpg=gpg2
    if ! type -t gpg1 >/dev/null; then
        alias gpg1=/usr/bin/gpg
    fi
fi

alias gpgk="gpg --no-default-keyring --keyring"
# TODO replace these with --homedir
alias gpgk.="gpg --no-default-keyring --keyring gnupg-ring:./pubring.gpg --secret-keyring ./secring.gpg --trustdb-name ./trustdb.gpg"

# SSH using gpg-agent as ssh agent (e.g. for smart card SSH)
alias sshg='SSH_AUTH_SOCK=~/.gnupg/S.gpg-agent.ssh ssh'
alias sshgpg='SSH_AUTH_SOCK=~/.gnupg/S.gpg-agent.ssh ssh'
alias scpgpg='SSH_AUTH_SOCK=~/.gnupg/S.gpg-agent.ssh scp'

launch-gpg-agent-ssh() {
    # launch if not running
    gpgconf --launch gpg-agent
    # use as SSH agent
    if [ -S "$HOME/.gnupg/S.gpg-agent.ssh" ]; then
        SSH_AUTH_SOCK="$HOME/.gnupg/S.gpg-agent.ssh"
    else
        SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)"
    fi
    export SSH_AUTH_SOCK
}

gpg-set-ssh-agent() {
    set_var_verbose SSH_AUTH_SOCK ~/.gnupg/S.gpg-agent.ssh
}

# use GPG as ssh-agent, not gnome-keyring
if [ -z "${SSH_AUTH_SOCK-}" ] \
   || [[ $SSH_AUTH_SOCK == /run/user/*/keyring/ssh ]]; then
    launch-gpg-agent-ssh
fi

# 1password CLI aliases
op-pw() {
    local pass
    pass="$(run op get item "$@" | \
        jq -r '.details.fields[] | select(.designation == "password").value')"
    echo "Making password available on X selection"
    echo -n "$pass" | run xclip -selection primary -l 1
}


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
alias cdu='colordiff -u'
alias mtime='stat --format=%y'
alias timeat='date +%s -d'
alias ips='ip -o addr show scope global | grep inet | cut -d" " -f 2,7 | cut -d/ -f1'
alias ds='dig +short'
alias dsa='dig-authoritative +short'
alias diga='dig-authoritative'

mydf() {
    if type -p pydf >/dev/null; then
        pydf | grep -v /snap/
    else
        df -h -x squashfs -x tmpfs -x devtmpfs
    fi
}

case "$OSTYPE" in
    linux-*)
        alias clip='xclip -selection clipboard'
        alias clip1='xclip -selection clipboard -loops 1'
        ;;
    darwin*)
        alias clip=pbcopy
        ;;
    *)
        echo >&2 "Unexpected \$OSTYPE: $OSTYPE"
esac

function wp() { dig +short txt "$*.wp.dg.cx"; } # wikipedia commandline
function calc() { echo "$*" | bc -l; } # simple calculator
alias findf='find . -name '
vimfindf() {
    local IFS
    IFS=$'\n'
    # shellcheck disable=SC2046
    vim -- $(find . -name "$@")
}
vimgg() {
    run git grep -lz "$@" | xargs -0 sh -xc 'vim "$@" < /dev/tty' vim
}
function search() { grep -rIn --color "$@" ./* ; }
function isearch() { grep -rIni --color "$@" ./* ; }
alias wgetn='wget -O /dev/null'
alias wget-='wget -O -'
function whichedit() { $EDITOR "$(which "$@")" ; }
function vimwhich() { vim "$(which "$@")" ; }
complete -c which whichedit vimwhich
alias du-fs='du -xh --max-depth 1'
alias syslog='less +F /var/log/syslog'
alias torssh="torsocks ssh -o ControlPath='~/.ssh/sockets/%r@%h-%p.tor'"
alias showx509='openssl x509 -noout -text -nameopt multiline -certopt no_sigdump -in'
alias strip-escapes='sed -r "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[m|K]//g"'

export RIPGREP_CONFIG_PATH="$HOME/.ripgreprc"
alias g='rg'

showx509chain() {
    if [ $# -ne 1 ]; then
        cat >&2 <<EOM
usage: $(basename "$0") CHAINFILE.crt

Print text info about all X.509 certificates in a file.
EOM
        return 1
    fi

    openssl crl2pkcs7 -nocrl -certfile "$1" \
        | openssl pkcs7 -print_certs -text -noout
}
showx509chaincat() {
    if [ $# -ne 1 ]; then
        cat >&2 <<EOM
usage: $(basename "$0") CHAINFILE.crt

Print all X.509 certificates in a file with subj/issuer headers.
EOM
        return 1
    fi

    openssl crl2pkcs7 -nocrl -certfile "$1" | openssl pkcs7 -print_certs
}

function awhois() { run whois "domain $1" ; }

function private() {
    export HISTFILE=/dev/null
    export ORIG_PS1="${ORIG_PS1:-$PS1}"
    export PS1="\[\e[30m\e[47m\]${ORIG_PS1%% }\[\e[m\] "
}

# just for fun
alias donotwant='rm -v'
alias DONOTWANT='rm -rfv'

# ruby aliases
alias gemi='gem install'
alias be='bundle exec'
rake() {
    if [ -e "$(git rev-parse --show-toplevel 2>/dev/null)/Gemfile" ]; then
        run bundle exec rake "$@"
    else
        command rake "$@"
    fi
}

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
        local var val
        var="$(echo "$env" | cut -d '=' -f 1)"
        val="$(echo "$env" | cut -d '=' -f 2-)"

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
    mv -iv "$2" "$1.$$" || return $?
    mv -iv "$1" "$2" || return $?
    mv -iv "$1.$$" "$1" || return $?
}

# set difference between two files
function setdiff() {
    if [ $# -lt 2 ]; then
        echo >&2 "usage: setdiff FILE1 FILE2"
        return 1
    fi

    head -c 0 "$1" || return $?
    head -c 0 "$2" || return $?

    comm -23 <(sort "$1") <(sort "$2")
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
    local log
    log=$(mktemp)
    date
    (time read -r -s -n1 _) >"$log" 2>&1
    date
    awk '/^real/ { print $2 }' "$log"
    rm -f "$log"
}

if [[ $OSTYPE != darwin* ]]; then
    open() {
        for i in "$@"; do
            xdg-open "$i"
        done
    }
fi

# like set -x
run() {
    echo >&2 "+ $*"
    "$@"
}

daterun() {
    date >&2 '+@ %F %T %z'
    echo >&2 "+ $*"
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

if [[ "$OSTYPE" != darwin* ]]; then
    say() {
        echo "$*" | festival --tts
    }
fi

# frequent cd paths
add_to_cdpath() {
    [ -d "$1" ] && export CDPATH="$CDPATH:$1"
}
if [ -z "${CDPATH-}" ]; then
    export CDPATH='.'
fi
add_to_cdpath "$HOME/code"
add_to_cdpath "$HOME/gov"
add_to_cdpath "$HOME/th"
add_to_cdpath "$HOME/stripe"
add_to_cdpath "$HOME/stripe/apiori"
add_to_cdpath "$HOME/stripe/ctf"

# search for command on $PATH
has_command() {
    type "$@" >/dev/null 2>&1
}

# vim as manpager
vman() {
    # shellcheck disable=SC2016
    MANPAGER=vimpager-wrapper man "$@"
}
if has_command vimpager-wrapper; then
    alias man=vman
fi

# aptitude aliases for brevity
alias aremove='sudo aptitude remove'
alias asearch='aptitude search'
alias ashow='aptitude show'
alias awhy='aptitude why'
alias dpkg-version="dpkg-query -Wf '\${Version}\n'"
alias apolicy='apt-cache policy'

if has_command apt; then
    alias aupdate='sudo apt update && sudo apt upgrade'
    alias aupgrade='sudo apt full-upgrade'
else
    alias aupdate='sudo aptitude update && sudo aptitude safe-upgrade'
    alias aupgrade='sudo aptitude full-upgrade'
fi

# ansible aliass
alias ansible-run-dry='sudo ansible-playbook -v /etc/ansible/site.yaml -l $HOSTNAME --check'
alias ansible-run='sudo ansible-playbook -v /etc/ansible/site.yaml -l $HOSTNAME'

ainstall() {
    local log="$HOME/install.log"
    for name in "$@"; do
        if ! awk '{print $NF}' "$log" | grep -x -- "$name" >/dev/null; then
            date "+%F %R	$name" >> "$log"
        fi
    done

    if has_command apt; then
        sudo apt install "$@"
    elif has_commant aptitude; then
        sudo aptitude install "$@"
    else
        sudo apt-get install "$@"
    fi
}

asnapinstall() {
    local log="$HOME/install.snap.log"
    for name in "$@"; do
        if ! awk '{print $NF}' "$log" | grep -x -- "$name" >/dev/null; then
            date "+%F %R	$name" >> "$log"
        fi
    done

    run snap install "$@"
}

git_commit_s() {
    local root
    root="$(git rev-parse --show-toplevel)" || return $?
    if [[ -e "$root/.sign-commits" && -z "${SKIP_GIT_SIGN-}" ]]; then
        git commit -S "$@"
    else
        git commit "$@"
    fi
}

# git aliases
alias ga='git add'
alias gb='git branch'
alias gg='git grep -I'
alias ggf='git grep -I -F'
alias ggp='git --no-pager grep -I'
alias gs='git status'
alias gss='git status --short'
alias gsh='git show'
alias gshw='git show --color-words'
alias gd='git diff'
alias gdc='git diff --cached'
alias gdcw='git diff --cached --color-words'
alias gdw='git diff --color-words' # git 1.7.2+
alias gdt='git difftool'
alias gmt='git mergetool'
alias gbr='git branch'
alias gco='git checkout'
alias gcoh='git checkout HEAD'
alias gco-='git checkout -'
alias gcom='git-checkout-main'
alias g-='git checkout -'
alias gc='git_commit_s'
alias gcs='git_commit_s -S'
alias gcsempty='git commit -S --allow-empty -m "Signed commit."'
alias gca='git_commit_s -a'
alias gcas='git_commit_s -aS'
alias gcam='git_commit_s -a --amend'
alias gcams='git_commit_s -a --amend -S'
alias gcm='git_commit_s --amend'
alias gcms='git_commit_s --amend -S'
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
alias glo='git log --oneline --decorate'
alias glsf='git log --stat --show-signature --pretty=fuller'
alias glf='git log --show-signature --pretty=fuller'

alias gr='git reset'
alias grH='git reset HEAD'
alias grh='git reset --hard'
grho() {
    run git reset --hard \
        "$(git rev-parse --abbrev-ref --symbolic-full-name '@{u}')"
}
alias grm='git ls-files -z --deleted | xargs -0 git rm'
alias grp='git rev-parse'
alias grpH='git rev-parse HEAD'
alias grv='git remote -v'
alias gru='git remote update'
alias gpl='git pull --ff-only'
alias gplr='git pull --rebase'
alias gps='git push'
alias gpss='git push stripe master && git push'
alias gpsu='git push --set-upstream origin $(git rev-parse --abbrev-ref HEAD)'
alias gpsr='git push || { git pull --rebase && { gcs || true; } && git push; }'
alias gpush='git push'
alias gpull='git pull'
alias gfetch='git fetch'
alias gfe='git fetch'
alias gfep='git fetch -p'
alias grb='git rebase'
alias gau='git-auto-update'

git-main-branch() {
    local ret
    git rev-parse --verify --quiet master >/dev/null && ret=$? || ret=$?

    case "$ret" in
        0)
            echo master
            return
            ;;
        1)
            # pass
            ;;
        *)
            return "$ret"
            ;;
    esac

    if git rev-parse --verify --quiet main >/dev/null; then
        echo main
    else
        echo >&2 "Neither master nor main exists"
        return 1
    fi
}

# check out the master/main branch
git-checkout-main() {
    local branch
    branch="$(git-main-branch)" || return $?
    run git checkout "$branch"
}
alias master=git-checkout-main
alias main=git-checkout-main

# show files changed in most recent commit
gf() {
    git show --pretty='format:' --name-only "$@" | grep -v '^$' | uniq \
        | sed -e "s#^#$(git rev-parse --show-toplevel)/#"
}
ge() {
    local IFS
    IFS=$'\n'
    # XXX TODO make sure IFS=$'\n' actually works
    # shellcheck disable=SC2046
    "$EDITOR" $(gf "${1-HEAD}")
}
gs-files() {
    git status --porcelain | grep -E '(^M|^A|^.M)' | cut -c 4- \
        | sed -e "s#^#$(git rev-parse --show-toplevel)/#"
}
gse() {
    local IFS
    IFS=$'\n'
    # TODO: make this handle spaces and special characters correctly
    # (need to de-quote the strings)
    # shellcheck disable=SC2046
    "$EDITOR" -- $(gs-files)
}
git-commit-mtime() {
    filename="$1"
    shift
    run git commit --date="$(stat --format=%y "$filename")" "$@"
}
alias gc-mtime=git-commit-mtime

alias p-r='hub pull-request'

# git doge
alias wow='git status'
alias such='git'
alias very='git'

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
#alias hl='hg log -G --color=always | less -R'
alias hl='hg log -G | less'

# cs161 aliases
alias runddd='ssh -MCX cs161 "(cd ~/cs161/root; ddd --debugger os161-gdb --gdb kernel)"'

# php syntax check
alias phpcheckhere='for file in *.php; do php -l $file; done'
alias phpcheck='find . -name "*.php" -exec php -l {} \;'

# tell shellcheck it's OK to follow source files
export SHELLCHECK_OPTS=-x

ssh-aupdate() {
    if [ $# -lt 1 ]; then
        echo ssh-aupdate HOST
        return 2
    fi
    local remotehost=$1
    shift
    echo "+ ssh $remotehost aupdate"
    # shellcheck disable=SC2029
    ssh -t "$remotehost" "sudo aptitude update && sudo aptitude safe-upgrade $*"
}

# grep ignoring .svn folders
grep-svn() {
    find . -path '*/.svn' -prune -o -type f -print0 | xargs -0 -e grep "$@"
}

# cd && ll
function c () {
    if [ -z "$*" ]; then
        cd && ll --color
    else
        cd "$*" && ll --color
    fi
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
# see also: dtrx
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
    local parent dir
    parent="$(dirname "$1")"
    dir="$(basename "$1")"
    run tar -czvf "$dir.tgz" -C "$parent" "$dir/"
}

addindent() {
    n="$1"
    # shellcheck disable=2183
    printf -v spaces '%*s' "$n"
    sed "s/^/$spaces/"
}

# programming
alias sml='rlwrap sml -Cprint.depth=3000 -Cprint.length=3000'
alias tcl='rlwrap tclsh'
alias math='rlwrap math'
alias py='ipython3'
alias py2='ipython'
alias py3='ipython3'
alias pysh='ipython3 -p sh'
alias per='poetry run'
export PYTHONBREAKPOINT=ipdb.set_trace

_pyval() {
    local python_cmd
    python_cmd="print $*"
    python -c "${python_cmd}"

    case "${shopts-}" in
        *noglob*) ;;
        *) set +f;;
    esac

    unset shopts
}

alias p='shopts="$SHELLOPTS"; set -f; _pyval'

# virtualenv activate
alias activate="source venv/bin/activate"

# Go/golang aliases
export GOPATH="$HOME/code/go"
alias cdgo='cd "$GOPATH"'
alias cdgoab='cd "$GOPATH/src/ab"'
alias cdgobin='cd "$GOPATH/bin"'
add_to_path "$GOPATH/bin"

# Used by pip
add_to_path ~/.local/bin
# pipx tab completion
if which register-python-argcomplete >/dev/null 2>&1; then
    eval "$(register-python-argcomplete pipx)"
fi
# poetry tab completion
if which poetry >/dev/null 2>&1; then
    eval "$(poetry completions bash)"
fi

# awscli bash completion
if which aws_completer >/dev/null 2>&1; then
    complete -C aws_completer aws
fi

# time long-running jobs
TIMER_LONG_JOBS=30
#TIMER_IGNORE_COMMANDS=( ssh vim bash )
#function _timer_parse_cmd {
#    echo $(basename "$1")
#}
function _timer_start {
    #_timer_parse_cmd $BASH_COMMAND
    timer=${timer:-$SECONDS}
}
function _timer_stop {
    [ -z "$timer" ] && return

    timer_show=$((SECONDS - timer))
    if (( timer_show > TIMER_LONG_JOBS )); then
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
#export LESS_TERMCAP_mb=$'\e[01;31m'       # begin blinking
#export LESS_TERMCAP_md=$'\e[01;38;5;74m'  # begin bold
#export LESS_TERMCAP_me=$'\e[0m'           # end mode
#export LESS_TERMCAP_se=$'\e[0m'           # end standout-mode
#export LESS_TERMCAP_so=$'\e[38;5;246m'    # begin standout-mode - info box
#export LESS_TERMCAP_us=$'\e[04;38;5;146m' # begin underline (purple)
export LESS_TERMCAP_us=$'\e[04;38;5;74m' # begin underline (blue)
export LESS_TERMCAP_ue=$'\e[0m'           # end underline
export LESS_TERMCAP_first=$'\e[0m'     # fake termcap to end underline in `env`

export EDITOR=vim
export DEBFULLNAME='Andy Brody'
export DEBEMAIL='git@abrody.com'

if [[ $OSTYPE == darwin* ]]; then
    # shellcheck source=/dev/null
    [ -r ~/.conf/bash_aliases.osx ] && source ~/.conf/bash_aliases.osx
fi

# Preserve history indefinitely
# It looks like this must be set in ~/.bashrc, and for some reason it doesn't
# work when this is set here. So just warn if we have a non-infinite size.
if [ -n "$HISTSIZE" ] || [ -n "$HISTFILESIZE" ]; then
    echo >&2 "Warning: HISTSIZE: $HISTSIZE, HISTFILESIZE: $HISTFILESIZE"
fi

if [ -d "$HOME/.rbenv/bin" ]; then
   export PATH="$PATH:$HOME/.rbenv/bin"
   if [ -x "$HOME/.rbenv/bin/rbenv" ]; then
       eval "$(rbenv init -)"
   fi
fi

# vim: ft=sh

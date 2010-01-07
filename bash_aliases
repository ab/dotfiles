alias gcc='gcc -std=c99 -Wall'
alias dir='ls --color=auto --format=vertical'
alias vdir='ls --color=auto --format=long'
alias ll='ls -l'
alias la='ls -A'
alias lla='ll -a'
alias l='ls -CF'
alias lt='ll -tr'
alias lless='ll --color=always | less -r'	# colored scrolling ll

# smtp port forwarding
alias abfasmail='ssh -Nf -L 2525:smtp.fas.harvard.edu:25 abrody@fas.harvard.edu'

alias cdh='cd "/home/andy/documents/Harvard/Junior 1/"'

# aptitude aliases for brevity
alias ainstall='sudo aptitude install'
alias aremove='sudo aptitude remove'
alias asearch='aptitude search'
alias ashow='aptitude show'
alias aupdate='sudo aptitude update && sudo aptitude safe-upgrade'
alias aupgrade='sudo aptitude full-upgrade'

# git aliases
alias g='git'
alias gb='git br'
alias gs='git status'
alias gd='git diff'
alias gbr='git br'
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


# php syntax check
alias phpcheck='for file in *.php; do php -l $file; done'

ssh-aupdate() {
	remotehost=$1
	shift
	echo ssh $remotehost aupdate
	ssh -t $remotehost "sudo aptitude update && sudo aptitude safe-upgrade $*"
}

# grep ignoring .svn folders
grep-svn() {
	find . -path '*/.svn' -prune -o -type f -print0 | xargs -0 -e grep $*
}

alias sml='rlwrap sml -Cprint.depth=3000 -Cprint.length=3000'

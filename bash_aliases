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

ssh-aupdate() {
	remotehost=$1
	shift
	echo ssh $remotehost aupdate
	ssh -t $remotehost "sudo aptitude update && sudo aptitude safe-upgrade $*"
}


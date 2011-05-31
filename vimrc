" ~/.vimrc
" agb rev 12

" === General ===

" Don't be vi-compatible
set nocompatible

" detect type of file
filetype on

" load filetype plugins
filetype plugin on

" load indent files for specific filetypes
filetype indent on

" syntax highlighting
syntax on

" dark background
set background=dark

" make backspace work normal (indent, eol, start)
" set backspace=2

" allow backspace and cursor keys to cross line boundaries
set whichwrap+=<,>,h,l

" use the mouse
"set mouse=a
set mouse=cih

" highlight as you type
set incsearch
set hlsearch
" ignore case when searching except if Caps
set ignorecase
set smartcase
" replace globally by default
set gdefault

" title customizations
set title
set titlestring=(%t)\ %{$USER}@%{hostname()}:\ vim\ %(%h\ %)%F\ %M titlelen=150

" take indent for new line from previous line
set autoindent

" sane tabs
set tabstop=4
set shiftwidth=4
set smarttab

" tabs, not spaces
set noexpandtab

" python files: indent with spaces
autocmd FileType python set expandtab
autocmd FileType python set textwidth=79
autocmd FileType python let g:detectindent_preferred_expandtab = 1
" also add a shebang automatically in new files
autocmd BufNewFile *.py 0put =\"#!/usr/bin/env python\<nl>\"|$

" ruby files: indent with 2 spaces
autocmd FileType ruby set expandtab
autocmd FileType ruby set tabstop=2
autocmd FileType ruby set shiftwidth=2
autocmd FileType ruby let g:detectindent_preferred_expandtab = 1
" also add a shebang automatically in new files
autocmd BufNewFile *.rb 0put =\"#!/usr/bin/env ruby\<nl>\"|$

" processing docs location
let processing_doc_path = "/opt/processing/reference"

" smarter ctags handling -- recurse up looking for tags file
set tags=./tags;$HOME

" === stuff ===
"" Hilight trailing whitespace and lines longer than 80 characters
"hi OverLength ctermbg=black guibg=black ctermfg=white cterm=none
hi OverLength cterm=underline gui=underline
hi ExtraWhitespace ctermbg=red guibg=red

" '\s\+$'         all trailing whitespace
" '\S\+\s\+'      whitespace following non-whitespace (highlight whole line)
" '\S\+\zs\s\+'   whitespace following non-whitespace
" '\S\+\zs\s\+\%#\@<!$'  as above, but don't highlight current line
call matchadd("ExtraWhitespace", '\S\+\zs\s\+\%#\@<!$')
"call matchadd("ExtraWhitespace", '\S\+\zs\s\+$')
autocmd InsertLeave * redraw!

"autocmd BufEnter * match ExtraWhitespace /\s\+$/
"autocmd InsertEnter * match ExtraWhitespace /\s\+\%#\@<!$/
"autocmd InsertLeave * match ExtraWhiteSpace /\s\+$/

"call matchadd("OverLength", '\%81v.\+')

" === Mappings ===

" ROT13
map <F12> ggVGg?

" make ctrl+x save
map <C-x> <esc>:confirm w<cr>

" make F1 not open a help browser
noremap <F1> <esc>
" TODO check that this actually works

" make q quit when viewing a man page
autocmd FileType man nnoremap <buffer> q :quit<cr>

" don't require shift when you want :
nnoremap ; :

" make ctrl+c copy to system clipboard when in visual mode
vmap <C-c> "+y

" make ctrl+p paste from the system clipboard when in normal mode
nmap <C-p> :set paste<cr>"+p:set nopaste<cr>:<esc><esc>

" make ctrl+h fill out the form of a global find and replace
if &gdefault
	map <C-h> <esc>:%s///<left><left>
else
	map <C-h> <esc>:%s///g<left><left><left>
endif


" steal ctrl+k from emacs
nmap <C-k> D
imap <C-k> <C-o>D

" rewrap current paragraph
map <F5> {gq}
imap <F5> <esc>{gq}kA

" spell checking
function! SpellOn()
	if ! &spell
		setlocal spell spelllang=en_us
		echo ":setlocal spell spelllang=en_us"
	endif
endfunction
map <silent> <F7> :call SpellOn()<cr>]s

" make w!! run sudo to write to a file
cmap w!! w !sudo tee > /dev/null %

" I accidentally hold down shift all the time
command W w
command Wq wq

" Comment a block
function! CommentBlock(...) range
	if a:0 >= 1
		let comment_regex = a:1
	else
		let slash_langs = ['php', 'c', 'cs', 'cpp', 'javascript', 'java']
		if index(slash_langs, &filetype) != -1
			let comment_regex = '// '
		elseif &filetype == 'tex'
			let comment_regex = '%\~ '
		elseif &filetype == 'vim'
			let comment_regex = '"\~ '
		else
			let comment_regex = '#\~ '
		endif
	endif
	let num_com = 0
	let num_un = 0
	" Step through each line in the range:
	for linenum in range(a:firstline, a:lastline)
		let line = getline(linenum)
		if line =~ '\s*' . comment_regex
			" remove comment
			let new = substitute(line, comment_regex, '', '')
			let num_un += 1
		else
			" add comment
			let new = substitute(line, '^\(\s*\)', '\1' . comment_regex, '')
			let num_com += 1
		endif
		call setline(linenum, new)
	endfor

	" Report what was done
	if num_com && num_un
		echo num_com "lines commented," num_un "lines uncommented"
	elseif num_com
		echo num_com "lines commented"
	elseif num_un
		echo num_un "lines uncommented"
	endif
endfunction
vmap <C-e> :call CommentBlock()<cr>


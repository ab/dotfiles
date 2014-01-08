" ~/.vimrc
" agb rev 17

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

" show graphical menu on tab completion
set wildmenu

" don't insert two spaces when joining after a period
set nojoinspaces

" title customizations
set title
set titlestring=(%t)\ %{$USER}@%{hostname()}:\ vim\ %(%h\ %)%F\ %M titlelen=150

" take indent for new line from previous line
set autoindent

" sane tabs
set tabstop=4
set shiftwidth=4
set smarttab

" spaces, not tabs
set expandtab

" python files
autocmd FileType python set textwidth=79
autocmd FileType python let g:detectindent_preferred_expandtab = 1
" also add a shebang automatically in new files
autocmd BufNewFile *.py 0put =\"#!/usr/bin/env python\<nl>\"|$

" ruby files: indent with 2 spaces
autocmd FileType {ruby,eruby} set textwidth=79
autocmd FileType {ruby,eruby} set tabstop=2
autocmd FileType {ruby,eruby} set shiftwidth=2
autocmd FileType {ruby,eruby} let g:detectindent_preferred_expandtab = 1
" also add a shebang automatically in new files
autocmd BufNewFile *.rb 0put =\"#!/usr/bin/env ruby\<nl>\"|$

" automatically treat puppet templates as eruby
autocmd BufRead,BufNewFile *puppet-config/*/templates/* set ft=eruby

" shell scripts
autocmd FileType sh set textwidth=79
" also add a shebang automatically in new files
autocmd BufNewFile *.sh 0put =\"#!/bin/sh\<nl>\"|$

" html files: indent with 2 spaces
autocmd FileType html set tabstop=2
autocmd FileType html set shiftwidth=2
autocmd FileType html let g:detectindent_preferred_expandtab = 1

" gitconfig
" use tabs
autocmd FileType gitconfig set noexpandtab

" processing docs location
let processing_doc_path = "/opt/processing/reference"

" smarter ctags handling -- recurse up looking for tags file
set tags=./tags;$HOME

" === plugin handling ===

runtime bundle/vim-pathogen/autoload/pathogen.vim
if exists("*pathogen#infect")
	call pathogen#infect()
endif

" Use <C-/>. for closetag so it plays nicer with TComment.
let b:closetag_mapleader = '<C-_>.'

" === stuff ===
"" Hilight trailing whitespace and lines longer than 80 characters
"hi OverLength ctermbg=black guibg=black ctermfg=white cterm=none
hi OverLength cterm=underline gui=underline
hi ExtraWhitespace ctermbg=red guibg=red

" '\s\+$'         all trailing whitespace
" '\S\+\s\+'      whitespace following non-whitespace (highlight whole line)
" '\S\+\zs\s\+'   whitespace following non-whitespace
" '\S\+\zs\s\+\%#\@<!$'  as above, but don't highlight current line
call matchadd("ExtraWhitespace", '\s\+\%#\@<!$')
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
" I've basically stopped using this, but keep it around for historical note
"map <C-x> :confirm w<cr>

" make <Leader><Leader> save
map <Leader><Leader> :confirm w<cr>

" make <Leader>q quit
map <Leader>q :confirm q<cr>

" make F1 escape rather than opening help
noremap <F1> <esc>
inoremap <F1> <esc>

" next buffer, prev buffer
map <Leader><PageDown> :bn!<cr>
map <Leader><PageUp> :bp!<cr>
map <Leader>] :bn!<cr>
map <Leader>[ :bp!<cr>
map <C-\><PageDown> <C-o>:bn!<cr>
map <C-\><PageUp> <C-o>:bp!<cr>
imap <C-\><PageDown> <C-o>:bn!<cr>
imap <C-\><PageUp> <C-o>:bp!<cr>

" close buffer
map <Leader>c :confirm bd<cr>
imap <C-\>c <esc>:confirm bd<cr>

" reload vimrc
map <Leader>r :source $MYVIMRC<cr>

" select current method
map <Leader>m ]MV[m

" make q quit when viewing a man page
autocmd FileType man nnoremap <buffer> q :quit<cr>

" don't require shift when you want :
" undecided about this one -- ; is useful
"nnoremap ; :

" make ctrl+c copy to system clipboard when in visual mode
vmap <C-c> "+y

" make ctrl+p paste from the system clipboard when in normal mode
nmap <C-p> :set paste<cr>"+p:set nopaste<cr>:<esc><esc>

" make ctrl+h fill out the form of a global find and replace
if &gdefault
	map <C-h> :%s///<left><left>
	vmap <C-h> :s///<left><left>
else
	map <C-h> :%s///g<left><left><left>
	vmap <C-h> :s///g<left><left><left>
endif

" make Y consistent with C and D
map Y y$

" steal ctrl+k from emacs
nmap <C-k> D
imap <C-k> <C-o>D

" make <Leader>x `chmod +x` current file
function! SetExecutableBit()
  let fname = expand("%:p")
  checktime
  execute "au FileChangedShell " . fname . " :echo"
  silent !chmod a+x %
  checktime
  execute "au! FileChangedShell " . fname
  redraw!
  echo "chmod +x " . fname
endfunction
command! Chmodx call SetExecutableBit()
map <Leader>x :Chmodx<cr>

" toggle paste mode
map <F3> :set paste!<cr>:set paste?<cr>
set pastetoggle=<F3>

" toggle taglist plugin
map <F4> :TlistToggle<CR>
imap <F4> <C-o><F4>

" rewrap current paragraph
map <F5> gwip
imap <F5> <C-o>gwip
" who needs Ex mode? make Q wrap things
map Q gw

" build ctags file in cwd
map <F6> :silent execute "!ctags -R" \| redraw!<cr>
imap <F6> <C-o><F6>

" build ctags file in directory of current file
" map <F6> :!cd `dirname %`; ctags -R
" imap <F6> <C-o>:!cd `dirname %`; ctags -R

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
command! -bang W w<bang>
command! -bang Wq wq<bang>

" CtrlP options
" set mapping to Ctrl-O
let g:ctrlp_map = '<c-o>'
" ignore various directories we don't want to search
let g:ctrlp_custom_ignore = {
  \ 'dir': '\v[\/]((\.(bundle|git|hg|svn|bzr))|vendor|node_modules)$',
  \ 'file': '\v\~$'
  \ }

" vim-gnupg options
" override default pattern of *.{gpg,asc,pgp}
let g:GPGFilePattern = '*.\(gpg\|pgp\)'

" ignore some files
set wildignore+=*.pyc

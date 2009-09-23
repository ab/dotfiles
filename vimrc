" ~/.vimrc
" agb rev 5

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

" take indent for new line from previous line
set autoindent

" sane tabs
set tabstop=4
set shiftwidth=4

" tabs, not spaces
set noexpandtab

" python files: indent with spaces
autocmd FileType python set expandtab

" ruby files: indent with 2 spaces
autocmd FileType ruby set expandtab
autocmd FileType ruby set tabstop=2
autocmd FileType ruby set shiftwidth=2

" === Mappings ===

" ROT13
map <F12> ggVGg?

" make ctrl+c copy to system clipboard when in visual mode
vmap <C-c> "+y


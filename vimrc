" ~/.vimrc
" agb rev 4

" === General ===

" Don't be vi-compatible
set nocompatible

" detect type of file
filetype on

" load filetype plugins
filetype plugin on

" load indent files for specific filetypes
filetype indent on

" dark background
set background=dark

" syntax highlighting
syntax on

" make backspace work normal (indent, eol, start)
" set backspace=2

" allow backspace and cursor keys to cross line boundaries
set whichwrap+=<,>,h,l

"" use the mouse for everything
"set mouse=a

" highlight as you type
set incsearch

" take indent for new line from previous line
set autoindent

" sane tabs
set tabstop=4

" unify
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


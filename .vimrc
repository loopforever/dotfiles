set nocompatible

set tabstop=2
set smarttab
set shiftwidth=2
set autoindent
set expandtab
set backspace=indent,eol,start

set number
set paste
set hlsearch
syntax on
filetype on

autocmd FileType make   set noexpandtab
autocmd FileType python set noexpandtab

map <leader>d :execute 'NERDTreeToggle ' . getcwd()<CR>

" User Interface
set guifont=Consolas\ 12
colorscheme molokai

if has("gui_running")
  winpos 0 0
  set lines=400 columns=200
endif

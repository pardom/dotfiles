" Plugins {{{

" Initialization {{{

if empty(glob('~/.vim/autoload/plug.vim'))
    silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin('~/.vim/plugged')

Plug 'chriskempson/base16-vim'
Plug 'junegunn/fzf.vim'
Plug 'scrooloose/nerdtree'
Plug 'sheerun/vim-polyglot'
Plug 'tpope/vim-sensible'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'

call plug#end()

" }}}

" Base16 {{{

if filereadable(expand("~/.vimrc_background"))
    let base16colorspace=256
    source ~/.vim/colorscheme.vim
endif

" }}}

" fzf {{{

set rtp+=/usr/local/opt/fzf

nnoremap <silent> <c-p> :FZF<cr>

" }}}

" vim-airline {{{

let g:airline#extensions#tabline#enabled = 1
let g:airline_powerline_fonts = 1

" }}}

" NERDTree {{{

map <silent> <c-n> :NERDTreeToggle<cr>

let g:NERDTreeQuitOnOpen = 1
let g:NERDTreeMinimalUI = 1
let g:NERDTreeWinSize = 50
let g:NERDTreeShowHidden = 1

" }}}

" }}}

" Appearance {{{

syntax on

set colorcolumn=100
set number
set ruler

" }}}

" Indentation {{{

set autoindent
set shiftwidth=4
set softtabstop=4
set tabstop=4

set expandtab
set si
set wrap
set lbr
set tw=120

filetype indent on

" }}}

" Folding {{{

set foldmethod=indent
set foldnestmax=10
set foldlevelstart=10

" }}}

" Mappings {{{

let mapleader = ","

" Write
noremap <silent> <leader>w :w<cr>
inoremap <silent> <leader>w <c-c>:w<cr>

" Quit
noremap <silent> <leader>q :q<cr>

" Buffers
nnoremap <silent> <tab> :bnext<cr>
nnoremap <silent> <s-tab> :bprevious<cr>

"

" vim:foldmethod=marker:foldlevel=0


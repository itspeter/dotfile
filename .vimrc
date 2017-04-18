"==============================================================================
"                               Vim Bundle
"==============================================================================
set nocompatible              " be iMproved, required
filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" alternatively, pass a path where Vundle should install plugins
"call vundle#begin('~/some/path/here')

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'
Plugin 'vim-airline/vim-airline'
Plugin 'junegunn/seoul256.vim'
Plugin 'kien/ctrlp.vim'

" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required
" To ignore plugin indent changes, instead use:
"filetype plugin on
"
" Brief help
" :PluginList       - lists configured plugins
" :PluginInstall    - installs plugins; append `!` to update or just :PluginUpdate
" :PluginSearch foo - searches for foo; append `!` to refresh local cache
" :PluginClean      - confirms removal of unused plugins; append `!` to auto-approve removal
"
" see :h vundle for more details or wiki for FAQ
" Put your non-Plugin stuff after this line
"

"==============================================================================
"                              End of Vim Bundle
"==============================================================================
" * About the airline
"   - Enable the list of buffers
let g:airline#extensions#tabline#enabled = 1
"   - Show just the filename
let g:airline#extensions#tabline#fnamemod = ':t'


" * About the vim theme
set t_Co=256
set term=xterm-256color
colo seoul256
syntax on
" https://superuser.com/questions/399296/256-color-support-for-vim-background-in-tmux
set t_ut= 

" * About the CtrlP
"   - Setup some default ignores
let g:ctrlp_custom_ignore = {
  \ 'dir':  '\v[\/](\.(git|hg|svn)|\_site)$',
  \ 'file': '\v\.(pyc|exe|so|dll|class|png|jpg|jpeg)$',
\}


" * Shortcut for tabs, and able to hidden
map <C-h> :bp<CR>
map <C-l> :bn<CR>
set hidden

" * Controlling the TABs
set expandtab
set shiftwidth=2
set softtabstop=2


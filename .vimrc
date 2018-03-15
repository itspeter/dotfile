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
set list
set listchars=tab:>-     " > is shown at the beginning, - throughout
set expandtab
set shiftwidth=2
set softtabstop=8

" * Controlling the line length
set cc=80

" * Show the line number
set number

" * Search related
set hlsearch  " Highlight
set incsearch  " Show the next match while entering a search

" * Experiment of deleting the default directory viewer - netrw
"   autocmd FileType netrw setl bufhidden=wipe  #Doesn't work for me.
"   src: https://github.com/tpope/vim-vinegar/issues/13
" TODO(itspeter):  Other choice is to vim-vingear
" Remove 'set hidden'
set nohidden
augroup netrw_buf_hidden_fix
    autocmd!

    " Set all non-netrw buffers to bufhidden=hide
    autocmd BufWinEnter *
                \  if &ft != 'netrw'
                \|     set bufhidden=hide
                \| endif

augroup end


" * Remove unwanted trailing spaces
"   src: http://vim.wikia.com/wiki/Remove_unwanted_spaces
autocmd FileType c,cc,cpp,h,py,java,php autocmd BufWritePre <buffer> %s/\s\+$//e

" * Load cscope
source ~/cscope_maps.vim


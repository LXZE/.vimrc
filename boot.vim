let s:dirname = expand("<sfile>:p:h")

set nocompatible
filetype off

set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
exe "source " . s:dirname . "/vundles.vim"
call vundle#end()

exe "source " . s:dirname . "/main.vim"
exe "source " . s:dirname . "/colqer.vim"
" colors dtinth256
" colorscheme jellybeans
color jellybeans
set pastetoggle=<leader>p

" An example for a vimrc file.
"
" Maintainer:	Bram Moolenaar <Bram@vim.org>
" Last change:	2002 Sep 19
"
" To use it, copy it to
"     for Unix and OS/2:  ~/.vimrc
"	      for Amiga:  s:.vimrc
"  for MS-DOS and Win32:  $VIM\_vimrc
"	    for OpenVMS:  sys$login:.vimrc

" When started as "evim", evim.vim will already have done these settings.
if v:progname =~? "evim"
	finish
endif

" Use Vim settings, rather then Vi settings (much better!).
" This must be first, because it changes other options as a side effect.
set nocompatible

" allow backspacing over everything in insert mode
set backspace=indent,eol,start

if has("vms")
	set nobackup		" do not keep a backup file, use versions instead
else
	set backup		" keep a backup file
endif
set history=50		" keep 50 lines of command line history
set ruler		" show the cursor position all the time
set showcmd		" display incomplete commands
set incsearch		" do incremental searching
set ic			" case insensitive

" For Win32 GUI: remove 't' flag from 'guioptions': no tearoff menu entries
" let &guioptions = substitute(&guioptions, "t", "", "g")

" Don't use Ex mode, use Q for formatting
map Q gq

" This is an alternative that also works in block mode, but the deleted
" text is lost and it only works for putting the current register.
"vnoremap p "_dp

" Switch syntax highlighting on, when the terminal has colors
" Also switch on highlighting the last used search pattern.
if &t_Co > 2 || has("gui_running")
	syntax on
	colo desert
	set hlsearch
endif

if has("autocmd")
" Only do this part when compiled with support for autocommands.

	" Enable file type detection.
	" Use the default filetype settings, so that mail gets 'tw' set to 72,
	" 'cindent' is on in C files, etc.
	" Also load indent files, to automatically do language-dependent indenting.
	filetype plugin indent on

	" Put these in an autocmd group, so that we can delete them easily.
	augroup vimrcEx
		au!

		" For all text files set 'textwidth' to 78 characters.
		autocmd FileType text setlocal textwidth=78

		" When editing a file, always jump to the last known cursor position.
		" Don't do it when the position is invalid or when inside an event handler
		" (happens when dropping a file on gvim).
		autocmd BufReadPost *
					\ if line("'\"") > 0 && line("'\"") <= line("$") |
					\   exe "normal g`\"" |
					\ endif

	augroup END

	autocmd FileType perl compiler perl
	autocmd FileType perl set number
	autocmd FileType c set number
	autocmd FileType cpp set number
	"autocmd FileType php compiler php
else

	"set autoindent		" always set autoindenting on

endif " has("autocmd")
map <F2> :w!<CR>
map <F3> :WMToggle<CR>
map <F4> :qall!<CR>
map <F5> :close<CR>
map <F6> GoDate: <Esc>:read !date<CR>kJ
" set include path
set path=.,../hdr/,../../hdr

" for taglist plugin
let Tlist_Ctags_Cmd="/usr/local/bin/ctags"
"set mouse=nv " enable the use of mouse in normal and visual mode 
set mouse=a
"set number
"set autoread

set backup!
if v:version >=700
"Set Current Line ,only for 7.0 
	set cursorline 
	if has("autocmd")
"		autocmd FileType c set spell 
"		autocmd FileType cpp set spell 
	endif
endif

if (&term == "dtterm")
        set bg=light
        hi visual ctermbg=0
else
        set bg=dark
endif

set tabstop=4
set shiftwidth=4
set ts=4
"set noexpandtab
set expandtab
set autoindent
"set foldmethod=indent
filetype on
autocmd FileType c,cpp,java set smartindent
if has("terminfo")
    set t_Co=16
    set t_AB=[%?%p1%{8}%<%t25;%p1%{40}%+%e5;%p1%{32}%+%;%dm
    set t_AF=[%?%p1%{8}%<%t22;%p1%{30}%+%e1;%p1%{22}%+%;%dm
else
    set t_Co=16
    set t_Sf=[3%dm
    set t_Sb=[4%dm
endif
set nu
set ruler
"colorscheme yellow
syntax on

"Go language
" Some Linux distributions set filetype in /etc/vimrc.
" Clear filetype flags before changing runtimepath to force Vim to reload them.
filetype off
filetype plugin indent off
set runtimepath+=$GOROOT/misc/vim
filetype plugin indent on
syntax on

" C++11 support
au BufNewFile,BufRead *.cpp set syntax=cpp11
au BufNewFile,BufRead *.cc set syntax=cpp11

" TagBar toggle
nmap tb :TagbarToggle<CR>

"--------------------
" Function: Open tag under cursor in new tab
" Source:   http://stackoverflow.com/questions/563616/vimctags-tips-and-tricks
"--------------------
" let g:tagbar_ctags_bin='/usr/local/bin/ctags'
let g:tagbar_width=26
"map <C-\> :tab split<CR>:exec("tag ".expand("<cword>"))<CR>
map <C-]> :tab split<CR>:exec("tag ".expand("<cword>"))<CR>
"map <A-]> :vsp <CR>:exec("tag ".expand("<cword>"))<CR>
"--------------------
" Function: Remap keys to make it more similar to firefox tab functionality
" Purpose:  Because I am familiar with firefox tab functionality
"--------------------
"map <C-T> :tabnew<CR>
"map <C-N> :!gvim &<CR><CR>
"map <C-W> :confirm bdelete<CR>

" Load ctags
if filereadable($CTAGS_TAG)
	set tags=$CTAGS_TAG
endif

" pathogen
execute pathogen#infect()

" Nerd Tree
" let g:NERDTreeDirArrows=0 " Do not use new arrows for directories
map <C-n> :NERDTreeToggle<CR>
let g:nerdtree_tabs_open_on_gui_startup=0 " no nerdtree_tabs by default

" CtrlP
set runtimepath^=~/.vim/bundle/ctrlp.vim

" Command-T
let g:CommandTAcceptSelectionMap = '<C-t>'
let g:CommandTAcceptSelectionTabMap = '<CR>'

" Highlight variable under cursor
autocmd CursorMoved * exe printf('match IncSearch /\V\<%s\>/', escape(expand('<cword>'), '/\'))

" Highlight all instances of word under cursor, when idle.
" Useful when studying strange source code.
" Type z/ to toggle highlighting on/off.
"
"nnoremap z/ :if AutoHighlightToggle()<Bar>set hls<Bar>endif<CR>
"function! AutoHighlightToggle()
"  let @/ = ''
"  if exists('#auto_highlight')
"    au! auto_highlight
"    augroup! auto_highlight
"    setl updatetime=4000
"    echo 'Highlight current word: off'
"    return 0
"  else
"    augroup auto_highlight
"      au!
"      au CursorHold * let @/ = '\V\<'.escape(expand('<cword>'), '\').'\>'
"    augroup end
"    setl updatetime=500
"    echo 'Highlight current word: ON'
"    return 1
"  endif
"endfunction

" set leader
let mapleader = " "

" turn on syntax highlighting
syntax on
filetype plugin on

" cursor position, terminal background
set ruler background=dark

" color column 80
set cc=80

" auto indent
set autoindent

" scroll speed
set scroll=8

" my funny javascript indentation
function GetDtinthIndent()

  let lnum = v:lnum
  let prevline = getline(lnum - 1)
  let line = getline(lnum)
  let indent = indent(lnum - 1)

  " don't bother re-indenting after a blank line
  if prevline =~ '^\s*$'
    return indent(lnum)
  endif

  " amd define: also don't indent
  if prevline =~ '^define('
    return indent(lnum)
  endif

  " now we check stuff
  let openbracket = (prevline =~ '{$')
  let prevclosebracket = (prevline =~ '^\s*}')
  let closebracket = (line =~ '^\s*}')
  let prevcomma = (prevline =~ '^\s*,')
  let comma = (line =~ '^\s*,')
  let prevvar = (prevline =~ '^\s*var\s')

  if prevclosebracket
    let open = GetOpenBracketLineNumber(lnum - 1)
    if open > 0
      let openline = getline(open)
      let openindent = indent(open)
      let opencomma = (openline =~ '^\s*,')
      if opencomma
        let prevcomma = opencomma
        let indent = openindent
      end
    end
  end

  let invar = 0
  if prevcomma
    let lnum2 = lnum - 1
    while getline(lnum2) =~ '^\s*,'
      let lnum2 -= 1
    endwhile
    if lnum2 > 0 && getline(lnum2) =~ '^\s*var'
      let invar = 1
    end
  end

  if closebracket && openbracket && prevcomma | return indent + 2 | end
  if closebracket && openbracket | return indent | end
  if openbracket && prevcomma | return indent + 4 | end
  if openbracket && !prevcomma | return indent + 2 | end
  if closebracket && prevcomma | return indent | end
  if closebracket && !prevcomma | return indent - 2 | end
  if prevvar && comma | return indent + 2 | end
  if prevcomma && !comma && invar | return indent - 2 | end
  if prevcomma && !comma && !invar | return indent + 2 | end
  if prevcomma && comma | return indent | end
  if !prevcomma && comma | return indent - 2 | end

  " if prevcomma && !openbracket | let indent -= 2 | end
  " if prevcomma && openbracket | let indent += 2 | end
  " if comma && (prevvar || prevcomma) | let indent += 2 | else | let indent -= 2 | end
  " if openbracket | let indent += 2 | end
  " if closebracket | let indent -= 2 | end
  " if prevclosebracket && OpenBracketIsAfterAComma(lnum - 1) | let indent -= 4 | end
  return indent

endfunction

function GetOpenBracketLineNumber(lnum)
  let lnum = a:lnum
  let level = 0
  while lnum > 0
    let line = getline(lnum)
    let openbracket = (line =~ '{$')
    let closebracket = (line =~ '^\s*}')
    if closebracket
      let level += 1
    elseif openbracket
      let level -= 1
      if level == 0
        return lnum
      end
    end
    let lnum -= 1
  endwhile
  return 0
endfunction


" allow backspacing over autoindent, linebreaks and starting point
set backspace=indent,eol,start

" set tab stops
set shiftwidth=2 tabstop=8 softtabstop=2 expandtab

" allow mouse usage
" set mouse=a

" other stuff
set title nowrap completeopt=menu dir=~/.vimtmp
set backupcopy=yes
set backupdir=~/.vimbackup

" searching: incremental, highlight, smart case
set incsearch hlsearch smartcase

" gui font
set guifont=Monaco:h14 

" show line number and command being entered
set showcmd number

" window width
"set winheight=10
"set winminheight=5
"set winheight=999

" COMMAND to use old-style tab
command Tab setl shiftwidth=4 tabstop=4 softtabstop=0 noexpandtab indentexpr=

" COMMAND to setup autocommands
command -nargs=* Auto au BufNewFile,BufRead <args>
command -nargs=* AutoType au FileType <args>

" COMMAND to fix typing mistakes
command Q q
command Wq wq
command WQ wq

augroup dtinth

  autocmd!

  " for markdown files: use 4 spaces
  AutoType markdown setl shiftwidth=4 softtabstop=4
  AutoType java Tab

  " mapping for csharp files
  AutoType cs setl shiftwidth=4 softtabstop=4
  " AutoType cs inoremap <buffer> ;wl Console.WriteLine("");<left><left><left>
  " AutoType cs inoremap <buffer> ;w; Console.Write("");<left><left><left>
  " AutoType cs inoremap <buffer> ;ip int.Parse()<left>
  " AutoType cs inoremap <buffer> ;dp double.Parse()<left>
  " AutoType cs imap <buffer> ;rl Console.ReadLine()

  " mapping for js files
  " AutoType javascript imap <buffer> ;rq ;req
  " AutoType javascript imap <buffer> ;req require('
  " AutoType javascript imap <buffer> ;ds describe('<esc>mda', function() {<cr>})<esc>`da
  " AutoType javascript imap <buffer> ;it it('should <esc>mda', function() {<cr>})<esc>`da

  " AutoType javascript set indentexpr=GetDtinthIndent() indentkeys+=0\,
  AutoType java Tab

augroup END

" http://news.ycombinator.com/item?id=1484280
" disable arrow keys
map <up> <nop>
map <down> <nop>
map <left> <nop>
map <right> <nop>
imap <up> <nop>
imap <down> <nop>
imap <left> <nop>
imap <right> <nop>

" map ctrl+s to save
map <c-s> :up<cr>
imap <c-s> <esc>:up<cr>

" map for easymotion
map <leader>a <leader><leader>F
map <leader>o <leader><leader>f

" map <leader>_ to select stuff
map <leader>w viw
map <leader>[ vi[
map <leader>] vi]
map <leader>{ vi{
map <leader>} vi}
map <leader>( vi(
map <leader>) vi)
map <leader>< vi<
map <leader>> vi>
map <leader>t vit
map <leader>b vib
map <leader>" vi"
map <leader>' vi'
map <leader>j 12j
map <leader>k 12k


" funny js
function! FunnyJS()
  syn match Error /^\s*[(\[]/ display
  syn match Error /;$/ display
endfunction

" nerdtree: auto quit and auto tree
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTreeType") && b:NERDTreeType == "primary") | q | endif

" remap <tab> to auto-complete
function InsertTabWrapper()
  if pumvisible()
    return "\<c-n>"
  endif
  if strpart(getline('.'), 0, col('.') - 1) =~ '\w$'
    if ShouldUseOmniCompletion()
      return "\<c-x>\<c-o>"
    endif
    return "\<c-n>"
  endif
  return "\<tab>"
endfunction

function ShouldUseOmniCompletion()
  let text = strpart(getline('.'), 0, col('.') - 1)
  let name = synIDattr(synID(line("."), col("."), 1), "name")
  if text =~ '</$' | return 1 | end
  if name =~ '^css' | return 1 | end
  return 0
endfunction

inoremap <Tab> <c-r>=InsertTabWrapper()<cr>
inoremap <S-tab> <c-p>

" ctrl-p
let g:ctrlp_map = '<leader>f'

" ignore some files in command-t
set wildignore+=*.o,*.obj,.git
set wildignore+=node_modules
set wildignore+=tmp/cache

" restore cursor positions ( taken from ubuntu's vimrc )
au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif

" bind run command
map <leader>r :call RunCustomCommand()<cr>
map <leader>s :call SetCustomCommand()<cr>
let g:silent_custom_command = 0
function! RunCustomCommand()
  up
  if g:silent_custom_command
    execute 'silent !' . s:customcommand
  else
    execute '!' . s:customcommand
  end
endfunction

function! SetCustomCommand()
  let s:customcommand = input('Enter Custom Command$ ')
endfunction

" rainbow rainbow!! 
let s:currentcolor = 9
function! ChangeColor()
  let s:currentcolor += 1
  if s:currentcolor >= 15
    let s:currentcolor = 9
  end
  exe "hi Comment ctermfg=" . s:currentcolor
endfunction

function! Rainbow()
  autocmd InsertEnter * call ChangeColor()
  autocmd InsertCharPre * call ChangeColor()
  autocmd CursorMoved * call ChangeColor()
endfunction

" from garybernhardt / dotfiles
function! MapCR()
  nnoremap <cr> :nohlsearch<cr>
endfunction
call MapCR()
autocmd! CmdwinEnter * :unmap <cr>
autocmd! CmdwinLeave * :call MapCR()
set t_ti= t_te=

let g:tern_map_keys=1
let g:EasyMotion_keys='tnseriaoplfuwydhjcxmvkbNEIOLUYHKMTSCV' " colemak ftw
let g:EclimCompletionMethod='omnifunc' " for eclim to work with YouCompleteMe
let g:EclimJavascriptLintEnabled=0
let g:EclimJavascriptValidate=0

let g:syntastic_html_checkers=[] " syntastic, don't complain about my awesome angular html6

function! SetupChord()
  Arpeggio inoremap fun function
  Arpeggio inoremap end end
  Arpeggio inoremap the the
  Arpeggio inoremap def def<CR>end<Up><Esc>A<Space>
  Arpeggio inoremap cla class<CR>end<Up><Esc>A<Space>
  Arpeggio inoremap {} {<CR>}<Esc>O<Tab>
  Arpeggio inoremap () () {<CR>}<Esc>O<Tab>
  Arpeggio inoremap con console.log()<Left>
  Arpeggio inoremap doe do<CR>end<Esc>O<Tab>
  Arpeggio inoremap thi this.
  Arpeggio inoremap req require('')<Left><Left>
  Arpeggio inoremap var var<Space>
  Arpeggio inoremap doc document.
  Arpeggio inoremap win window.
  Arpeggio inoremap pro .prototype.
  Arpeggio inoremap ary Array
  Arpeggio inoremap obj Object
  Arpeggio inoremap ret return<Space>
  Arpeggio inoremap le .length
  Arpeggio inoremap arg arguments
  Arpeggio inoremap ;f ;(function() {<Cr>})()<Esc>O<Tab>
  Arpeggio inoremap 9f (function)<Left>
  Arpeggio inoremap ar <C-w>
  Arpeggio inoremap io <C-w>
  Arpeggio inoremap stne <Esc>
endfunction

autocmd VimEnter * call SetupChord()
let g:arpeggio_timeoutlen=16

inoremap <C-c> <Esc>




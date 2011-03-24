"Use Vim settings, rather then Vi settings (much better!).
"This must be first, because it changes other options as a side effect.
set nocompatible

"allow backspacing over everything in insert mode
set backspace=indent,eol,start

"store lots of :cmdline history
set history=1000

set showcmd     "show incomplete cmds down the bottom
set showmode    "show current mode down the bottom

set incsearch   "find the next match as we type the search
set hlsearch    "hilight searches by default

set nowrap      "dont wrap lines
set linebreak   "wrap lines at convenient points

"statusline setup
set statusline=%f       "tail of the filename

"display a warning if fileformat isnt unix
set statusline+=%#warningmsg#
set statusline+=%{&ff!='unix'?'['.&ff.']':''}
set statusline+=%*

"display a warning if file encoding isnt utf-8
set statusline+=%#warningmsg#
set statusline+=%{(&fenc!='utf-8'&&&fenc!='')?'['.&fenc.']':''}
set statusline+=%*

set statusline+=%h      "help file flag
set statusline+=%y      "filetype
set statusline+=%r      "read only flag
set statusline+=%m      "modified flag

"display a warning if &et is wrong, or we have mixed-indenting
set statusline+=%#error#
set statusline+=%{StatuslineTabWarning()}
set statusline+=%*

set statusline+=%{StatuslineTrailingSpaceWarning()}

set statusline+=%{StatuslineLongLineWarning()}

set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

"display a warning if &paste is set
set statusline+=%#error#
set statusline+=%{&paste?'[paste]':''}
set statusline+=%*

" git status if applicable
set statusline+=%{fugitive#statusline()}

set statusline+=%=      "left/right separator
set statusline+=%{StatuslineCurrentHighlight()}\ \ "current highlight
set statusline+=%c,     "cursor column
set statusline+=%l/%L   "cursor line/total lines
set statusline+=\ %P    "percent through file
set laststatus=2

"recalculate the trailing whitespace warning when idle, and after saving
autocmd cursorhold,bufwritepost * unlet! b:statusline_trailing_space_warning

"return '[\s]' if trailing white space is detected
"return '' otherwise
function! StatuslineTrailingSpaceWarning()
    if !exists("b:statusline_trailing_space_warning")
        if search('\s\+$', 'nw') != 0
            let b:statusline_trailing_space_warning = '[\s]'
        else
            let b:statusline_trailing_space_warning = ''
        endif
    endif
    return b:statusline_trailing_space_warning
endfunction


"return the syntax highlight group under the cursor ''
function! StatuslineCurrentHighlight()
    let name = synIDattr(synID(line('.'),col('.'),1),'name')
    if name == ''
        return ''
    else
        return '[' . name . ']'
    endif
endfunction

"recalculate the tab warning flag when idle and after writing
autocmd cursorhold,bufwritepost * unlet! b:statusline_tab_warning

"return '[&et]' if &et is set wrong
"return '[mixed-indenting]' if spaces and tabs are used to indent
"return an empty string if everything is fine
function! StatuslineTabWarning()
    if !exists("b:statusline_tab_warning")
        let tabs = search('^\t', 'nw') != 0
        let spaces = search('^ ', 'nw') != 0

        if tabs && spaces
            let b:statusline_tab_warning =  '[mixed-indenting]'
        elseif (spaces && !&et) || (tabs && &et)
            let b:statusline_tab_warning = '[&et]'
        else
            let b:statusline_tab_warning = ''
        endif
    endif
    return b:statusline_tab_warning
endfunction

"recalculate the long line warning when idle and after saving
autocmd cursorhold,bufwritepost * unlet! b:statusline_long_line_warning

"return a warning for "long lines" where "long" is either &textwidth or 80 (if
"no &textwidth is set)
"
"return '' if no long lines
"return '[#x,my,$z] if long lines are found, were x is the number of long
"lines, y is the median length of the long lines and z is the length of the
"longest line
function! StatuslineLongLineWarning()
    if !exists("b:statusline_long_line_warning")
        let long_line_lens = s:LongLines()

        if len(long_line_lens) > 0
            let b:statusline_long_line_warning = "[" .
                        \ '#' . len(long_line_lens) . "," .
                        \ 'm' . s:Median(long_line_lens) . "," .
                        \ '$' . max(long_line_lens) . "]"
        else
            let b:statusline_long_line_warning = ""
        endif
    endif
    return b:statusline_long_line_warning
endfunction

"return a list containing the lengths of the long lines in this buffer
function! s:LongLines()
    let threshold = (&tw ? &tw : 80)
    let spaces = repeat(" ", &ts)

    let long_line_lens = []

    let i = 1
    while i <= line("$")
        let len = strlen(substitute(getline(i), '\t', spaces, 'g'))
        if len > threshold
            call add(long_line_lens, len)
        endif
        let i += 1
    endwhile

    return long_line_lens
endfunction

"find the median of the given array of numbers
function! s:Median(nums)
    let nums = sort(a:nums)
    let l = len(nums)

    if l % 2 == 1
        let i = (l-1) / 2
        return nums[i]
    else
        return (nums[l/2] + nums[(l/2)-1]) / 2
    endif
endfunction

"indent settings
set shiftwidth=4
set softtabstop=4
set expandtab
set autoindent

"folding settings
set foldmethod=indent   "fold based on indent
set foldnestmax=3       "deepest fold is 3 levels
set nofoldenable        "dont fold by default

set wildmode=list:longest   "make cmdline tab completion similar to bash
set wildmenu                "enable ctrl-n and ctrl-p to scroll thru matches
" set wildignore=*.o,*.obj,*~ "stuff to ignore when tab completing
set wildignore=*.o,*.obj,*~,pkg/*

"display tabs and trailing spaces
set list
set listchars=tab:▷⋅,trail:⋅,nbsp:⋅

set formatoptions-=o "dont continue comments when pushing o/O
set nojoinspaces

"vertical/horizontal scroll off settings
set scrolloff=3
set sidescrolloff=7
set sidescroll=1

"turn on syntax highlighting
syntax on

"some stuff to get the mouse going in term
set mouse=a
set ttymouse=xterm2

"tell the term has 256 colors
set t_Co=256

"hide buffers when not displayed
set hidden

"dont load csapprox if we no gui support - silences an annoying warning
if !has("gui")
    let g:CSApprox_loaded = 1
endif

"make <c-l> clear the highlight as well as redraw
nnoremap <C-L> :nohls<CR><C-L>
inoremap <C-L> <C-O>:nohls<CR>

"map to bufexplorer
nnoremap <C-B> :BufExplorer<cr>

" from the fuzzyfinder docs:
nnoremap <silent> <C-n>      :FufBuffer<CR>
" nnoremap <silent> <C-f>p     :FufFile<CR>
" nnoremap <silent> <C-f>f     :FufFile<CR>
" nnoremap <silent> <C-f>     :FufFile<CR>
" nnoremap <silent> <C-f><C-t> :FufTag<CR>
" nnoremap <silent> <C-f>t     :FufTag!<CR>
noremap  <silent> g]         :FufTagWithCursorWord!<CR>

noremap <silent> <C-f> :CommandT<CR>

"map Q to something useful
noremap Q gq

"make Y consistent with C and D
nnoremap Y y$

" easy escape
imap jj <Esc>

"mark syntax errors with :signs
let g:syntastic_enable_signs=1

"snipmate setup
" source ~/.vim/bundle/snipmate/snippets/support_functions.vim
" autocmd vimenter * call s:SetupSnippets()
" function! s:SetupSnippets()

"     "if we're in a rails env then read in the rails snippets
"     if filereadable("./config/environment.rb")
"         call ExtractSnips("~/.vim/snippets/ruby-rails", "ruby")
"         call ExtractSnips("~/.vim/snippets/eruby-rails", "eruby")
"     endif

"     call ExtractSnips("~/.vim/snippets/html", "eruby")
"     call ExtractSnips("~/.vim/snippets/html", "xhtml")
"     call ExtractSnips("~/.vim/snippets/html", "php")
" endfunction
let g:snippets_dir="~/.vim/bundle/snipmate/snippets"

"visual search mappings
function! s:VSetSearch()
    let temp = @@
    norm! gvy
    let @/ = '\V' . substitute(escape(@@, '\'), '\n', '\\n', 'g')
    let @@ = temp
endfunction
vnoremap * :<C-u>call <SID>VSetSearch()<CR>//<CR>
vnoremap # :<C-u>call <SID>VSetSearch()<CR>??<CR>


"jump to last cursor position when opening a file
"dont do it when writing a commit log entry
autocmd BufReadPost * call SetCursorPosition()
function! SetCursorPosition()
    if &filetype !~ 'commit\c'
        if line("'\"") > 0 && line("'\"") <= line("$")
            exe "normal! g`\""
            normal! zz
        endif
    end
endfunction

"define :HighlightLongLines command to highlight the offending parts of
"lines that are longer than the specified length (defaulting to 80)
command! -nargs=? HighlightLongLines call s:HighlightLongLines('<args>')
function! s:HighlightLongLines(width)
    let targetWidth = a:width != '' ? a:width : 79
    if targetWidth > 0
        exec 'match Todo /\%>' . (targetWidth) . 'v/'
    else
        echomsg "Usage: HighlightLongLines [natural number]"
    endif
endfunction
call pathogen#runtime_append_all_bundles()

"load ftplugins and indent files
filetype off
filetype plugin on
filetype indent on

" ********************************************************************************
" ********************************************************************************
" ********************************************************************************
"
" now, personal settings, now that the scrooloose vim stuff is out of the way:
"
" ********************************************************************************
" ********************************************************************************
" ********************************************************************************

" scrooloose overrides
set listchars=tab:⋅⋅,trail:⋅,nbsp:⋅

set tabstop=2
set softtabstop=2
set shiftwidth=2

set wrap
set linebreak
set textwidth=120

" plugin setup
let g:NERDTreeMapOpenSplit = 'i'
let g:NERDTreeIgnore = ['\~$', '^tags$']
" let NERDTreeChDirMode=2 " auto-change CWD when changing tree root
command -n=? -complete=dir NT NERDTreeToggle <args>
" au TabLeave * call s:nerd_close()

let g:NERDSpaceDelims = 1 " include space in comments

" command Rescan :ruby finder.rescan!
let mapleader=','
map <silent> <Leader>r :echo 'refreshing tags and files...'<CR>:silent !ctags -R<CR>:silent CommandTFlush<CR>:echo 'refreshed tags and files'<CR>

let g:CommandTMatchWindowAtTop=1
" let g:fuzzy_ignore = "gems*;pkg/*"
" for commandt ignores, see: wildignore

" tab movement setup
" all this tab mojo is from ara.t.howard

" this lets 'tt' toggle between tabs
let g:tabno=tabpagenr()
au TabLeave * :let g:tabno = tabpagenr()
map tt :exec 'normal !'.g:tabno.'gt'<CR>

" map 'tn' to tabnext - a count is relative from current pos
" function TabNext()
"     exec 'tabn'
" endfunction
" map tn :call TabNext()<CR>

" tab/cursor movement mappings
" note that this overwrites <C-L> for :nohlsearch

" map 'tg' to 'tab go' - this is an absolute tab number and quite useful with 'tt'
" map tg gt
" map <C-j> gt

" map 'tp' to 'tab previous'
" map tp gT
" map <C-k> gT

" ctrl-j and ctrl-k move tabs left(j)/right(k)
" map <C-h> :call TabMove(1)<CR>
" map <C-j> :call TabMove(1)<CR>
" map <C-k> :call TabMove(0)<CR>
" map <C-l> :call TabMove(0)<CR>
function TabMove(n)
    let nr = tabpagenr()
    let size = tabpagenr('$')
    " do we want to go left?
    if (a:n != 0)
        let nr = nr - 2
    endif
    " crossed left border?
    if (nr < 0)
        let nr = size-1
        " crossed right border?
    elseif (nr == size)
        let nr = 0
    endif
    " fire move command
    exec 'tabm'.nr
endfunction

" map <C-J> <C-W>j<C-W>_
" map <C-K> <C-W>k<C-W>_
map <C-j> <C-w>j
map <C-k> <C-w>k
map <C-h> <C-w>h
map <C-l> <C-w>l
map <C-_> <C-w>_

map <C-Left> :call TabMove(1)<CR>
map <C-Right> :call TabMove(0)<CR>


" everything else...

" colorscheme desert " make it look nice in terminal.app
colorscheme molokai

set number

" from evilchelu
nnoremap gb '[V']

" command W w !sudo tee % > /dev/null

set winheight=10   " current window always has a nice size
set winminheight=3 " but the other windows aren't *too* small

set splitbelow
set splitright

" strip leading tabs and trailing whitespace
command Tr %s/\s\+$//ge | %s/\t/  /ge | nohlsearch
command FixHashes %s/\(\S\)=>\(\S\)/\1 => \2/ge | %s/\t/  /ge | nohlsearch

" set directory=~/.vimswap
" livin' on the edge!
set noswapfile

" settings from jeremy hinegardner:

" wildmatching
" set wildmode=list:longest " make cmdline tab completion similar to bash
" set wildmenu              " enable ctrl-n and ctrl-p to scroll through matches
" set wildignore=*.o,*.obj,*~
"
" completion additions.
" set popumen to display longest match on popup even if only one match
" set completeopt=menuone,longest

" from http://vim.wikia.com/wiki/Change_vimrc_with_auto_reload
" autocmd BufWritePost .vimrc source %

" from http://pastie.org/359759 / evan phoenix
" overridden by the snippets plugin so it doesn't work...
" function! CleverTab()
"     if strpart( getline('.'), 0, col('.')-1 ) =~ '^\s*$'
"         return "\<Tab>"
"     else
"         return "\<C-N>"
" endfunction
" inoremap <Tab> <C-R>=CleverTab()<CR>

" formatoptions get overridden by the ftplugin stuff built-ins
" see http://peox.net/articles/vimconfig.html for more info
" from http://www.oreillynet.com/onlamp/blog/2005/07/vim_its_slim_and_trim_heres_wh.html

" function ClosePair(char)
"   if getline('.')[col('.') - 1] == a:char
"     return "\<Right>"
"   else
"     return a:char
"   endif
" endf
" inoremap ( ()<ESC>i
" inoremap ) <C-R>=ClosePair(')')<CR>
" inoremap { {}<ESC>i
" inoremap } <C-R>=ClosePair('}')<CR>
" inoremap [ []<ESC>i
" inoremap ] <C-R>=ClosePair(']')<CR>

" http://www.omnigroup.com/mailman/archive/macosx-admin/2004-June/047237.html
" autocmd FileType crontab :set backupcopy=yes
" which doesn't seem to work, even with mvim -f. EDITOR=vim now instead of mvim...
" from the guioptions help, -f doesn't behave properly with macvim

" http://vim.wikia.com/wiki/Disable_F1_built-in_help_key
nmap <F1> :echo<CR>
imap <F1> <C-o>:echo<CR>

" auto-reload any file modified outside vim
set autoread

" but from http://old.nabble.com/Automatically-reload-file-on-change-td15247242.html
" it's possible to set a group instead, e.g. for log files
" augroup vimrcAu
"   au!
"   au BufEnter,BufNew Test.log setlocal autoread
" augroup END

set tags=./tags,tags

au BufEnter /private/tmp/crontab.* setl backupcopy=yes


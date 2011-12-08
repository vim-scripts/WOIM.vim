" Vim syntax and filetype plugin for WOIM files (.woim)
" Language:	Self defined markup and functions for WOIM lists in Vim
" Author:	Geir Isene <g@isene.com>
" Web_site:	http://isene.com/
" WOIM_def:	http://isene.com/woim.pdf
" License:	I release all copyright claims. 
"		This code is in the public domain.
"		Permission is granted to use, copy modify, distribute, and
"		sell this software for any purpose. I make no guarantee
"		about the suitability of this software for any purpose and
"		I am not liable for any damages resulting from its use.
"		Further, I am under no obligation to maintain or extend
"		this software. It is provided on an 'as is' basis without
"		any expressed or implied warranty.
" Version:	1.6 - compatible with the WOIM definition v. 1.6
" Modified:	2011-12-08
"
" Changes since previous version:
"   Added marking of literal regions with special marking of start/end ("/")
"   Added <leader><DOWN> and <leader><UP>
"   Fixed syntax marking for State/Transitions where indent is "*"
"   Fixed escaping "\", "{" and "}" for LaTeX conversion

" INSTRUCTIONS {{{1
"
" Use tabs/shifts or * for indentations
"
" Use <SPACE> to toggle one fold
" Use \0 to \9, \a, \b, \c, \d, \e, \f to show up to 15 levels expanded
"
" Use <leader>s to remove underlining of States (prefixed with S:)
" Use <leader>S to add underlining of States (prefixed with S:)
" Use <leader>t to remove underlining of Transitions (prefixed with T:)
" Use <leader>T to add underlining of Transitions (prefixed with T:)
"
" Use <leader>v to add a checkbox at start of item or to toggle a checkbox
" Use <leader>V to add/toggle a checkbox with a date stamp for completion
"
" Use <leader><SPACE> to go to the next open template element
" (A template element is a WOIM item ending in an equal sign)
"
" g<DOWN> or g<UP> to view only the current line and its ancestors.
" An alternative is <leader><DOWN> and <leader><UP> to open more levels down.
" 
" Use <leader>L to convert the entire document to LaTaX

" Use <leader>z encrypts the current line (including all sublevels if folded)
" Use <leader>Z encrypts the current file (all lines)
" Use <leader>x decrypts the current line
" Use <leader>X decrypts the current file (all lines)
"
" A dot file (file name starts with a "." such as .test.woim) is
" automatically encrypted on save and decrypted on opening.
"
" Syntax updated at start and every time you leave Insert mode
" As a sort of "presentation mode", you can traverse a WOIM list by using


" Initializing {{{1
if version < 600
    syntax clear
elseif exists("b:current_syntax")
    finish
endif

" Basic settings {{{1
let b:current_syntax="WOIM"
set autoindent
set textwidth=0
set shiftwidth=2
set tabstop=2
set softtabstop=2
set noexpandtab
set foldmethod=syntax
set fillchars=fold:\ 
syn sync fromstart
autocmd InsertLeave * :syntax sync fromstart

" Functions {{{1

" Folding {{{2
" Mapped to <SPACE> and <leader>0 - <leader>f
set foldtext=WOIMFoldText()
function! WOIMFoldText()
  let line = getline(v:foldstart)
  let myindent = indent(v:foldstart)
  let line = substitute(line, '^\s*', '', 'g')
  while myindent != 0
    let myindent = myindent - 1
    let line = ' ' . line
  endwhile
  return line
endfunction

" Checkbox and timestamp {{{2
" Mapped to <leader>v and <leader>V
function! CheckItem (stamp)
  let current_line = getline('.')
  if match(current_line,'\V[_]') >= 0
    let time = strftime("%Y-%m-%d %H.%M")
    exe 's/\V[_]/[x]/'
    if a:stamp == "stamped"
      exe "normal 0f]a ".time.":"
    endif
  elseif match(current_line,'\V[x]') >= 0
    exe 's/\V[x]/[_]/i'
    exe 's/\V[_] \d\d\d\d-\d\d-\d\d \d\d\.\d\d:/[_]/e'
  else
    exe "normal ^i[_] "
  endif
endfunction

" Goto reference {{{2
" Mapped to 'gr'
function! GotoRef()
  let current_line = getline('.')
  if match(current_line,'#') >= 0
    if match(current_line,"#\'") >= 0
      let ref_word = matchstr(current_line,"#\'.*\'")
	  let ref_word = substitute(ref_word, "\'", '', 'g')
      let ref_word = substitute(ref_word, '#', '', 'g')
      let ref_dest = substitute(ref_word, '/', '.*\\n\\s*.\\{-}', 'g')
	  let ref_dest = "\\\(#\\\'\\\)\\\@<!" . ref_dest
	else
      if match(current_line,"#.* ") >= 0
        let ref_word = matchstr(current_line,"#.* ")
	  else
        let ref_word = matchstr(current_line,"#.*$")
	  endif
      let ref_word = substitute(ref_word, '#', '', 'g')
      let ref_dest = substitute(ref_word, '/', '.*\\n\\s*.\\{-}', 'g')
	  let ref_dest = "#\\\@<!" . ref_dest
	endif
    let @/ = ref_dest
	call search(ref_dest)
    let new_line = getline('.')
    if new_line == current_line
	  echo "No destination"
	endif
  else
    echo "No reference in the WOIM item"
  endif
endfunction

"LaTeX conversion{{{2
"Mapped to '<leader>L'
function! LaTeXconversion ()
    try
        "Escape "\"
        execute '%s/\\/\\\\/g'
    catch
    endtry
    try
        "Escape "{"
        execute '%s/{/\\{/g'
    catch
    endtry
    try
        "Escape "}"
        execute '%s/}/\\}/g'
    catch
    endtry
    try
        "WOIMb
        execute '%s/ \@<=\*\(.\{-}\)\* /\\textbf{ \1 }/g'
    catch
    endtry
    try
        "WOIMi
        execute '%s/ \@<=\/\(.\{-}\)\/ /\\textsl{ \1 }/g'
    catch
    endtry
    try
        "WOIMu
        execute '%s/ \@<=_\(.\{-}\)_ /\\underline{ \1 }/g'
    catch
    endtry
    try
        "WOIMindent
        execute '%s/\(\t\|\*\)\@<=\([0-9.]\+\.\s\)/\1\\textcolor{v}{\2}/g'
    catch
    endtry
    try
        "WOIMmulti
        execute '%s/\(\t\|\*\)+/\\tab \\textcolor{r}{+}/g'
    catch
    endtry
    try
        "WOIMref
        execute "%s/\\(#\\{1,2}\\(\\'[a-zA-ZæøåÆØÅ0-9,.:/ _&?%=\\-\\*]\\+\\'\\|[a-zA-ZæøåÆØÅ0-9.:/_&?%=\\-\\*]\\+\\)\\)/\\\\textcolor{v}{\\1}/g"
    catch
    endtry
    try
        "WOIMquote
        execute '%s/\(\".*\"\)/\\textcolor{t}{\1}/g'
    catch
    endtry
    try
        "WOIMcomment
        execute '%s/\((.*)\)/\\textcolor{t}{\1}/g'
    catch
    endtry
    try
        "WOIMmove
        execute '%s/\(>>\|<<\|->\|<-\)/\\textbf{\1}/g'
    catch
    endtry
    try
    try
        "WOIMqual
        execute '%s/\(\[.\{-}\]\)/\\textcolor{g}{\1}/g'
    catch
    endtry
    try
        "WOIMop
        execute "%s/\\(\\s\\|\\*\\)\\@<=\\([A-ZÆØÅ_/]\\{-2,}:\\s\\)/\\\\textcolor{b}{\\2}/g"
    catch
    endtry
    try
        "WOIMtag
        execute "%s/\\(\\s\\|\\*\\)\\@<=\\([a-zA-ZæøåÆØÅ0-9,._&?%= \\-\\/+<>#']\\{-2,}:\\s\\)/\\\\textcolor{r}{\\emph{\\2}}/g"
    catch
    endtry
    try
        "WOIMsc
        execute '%s/\(;\)/\\textcolor{g}{\1}/g'
    catch
    endtry
    "Substitute tabs + space in second line of multi-item
        execute '%s/\(\t\|\*\)  /\\tab \\tab /g'
    catch
    endtry
    try
    "Substitute tabs
        execute '%s/\(\t\|\*\)/\\tab /g'
    catch
    endtry
    "Document start
    normal ggO%Created by the WOIM vim plugin, see:
    normal o%http://vim.sourceforge.net/scripts/script.php?script_id=2518
    normal o
    normal o\documentclass[10pt]{article}
    normal o\usepackage[margin=1cm]{geometry}
    normal o\usepackage[usenames]{color}
    normal o\usepackage{alltt}
    normal o\newcommand{\tab}{\hspace*{2em}}
    normal o\definecolor{r}{rgb}{0.5,0,0}
    normal o\definecolor{g}{rgb}{0,0.5,0}
    normal o\definecolor{b}{rgb}{0,0,0.5}
    normal o\definecolor{v}{rgb}{0.4,0,0.4}
    normal o\definecolor{t}{rgb}{0,0.4,0.4}
    normal o
    normal o\begin{document}
    normal o\begin{alltt}
    "Document end
    normal Go\end{alltt}
    normal o\end{document}
endfunction

" Syntax definitions {{{1

" WOIM elements {{{2
" Identifier (any number in front)
syn match   WOIMident   "\(\t\|\*\)*[0-9.]\+\.\s"

" Multi-line
syn match   WOIMmulti   "^\(\t\|\*\)*+"

" Qualifiers are enclosed within [ ]
syn match   WOIMqual    "\[.\{-}\]" contains=WOIMtodo,WOIMref,WOIMcomment

" Tags - anything that ends in a colon
syn match   WOIMtag	'\(\s\|\*\)\@<=[a-zA-ZæøåÆØÅ0-9,._&?%= \-\/+<>#']\{-2,}:\s' contains=WOIMtodo,WOIMcomment,WOIMquote,WOIMref

" WOIM operators
syn match   WOIMop	'\(\s\|\*\)\@<=[A-ZÆØÅ_/]\{-2,}:\s' contains=WOIMcomment,WOIMquote

" Mark semicolon as stringing together lines
syn match   WOIMsc	";"

" References start with a hash (#)
syn match   WOIMref	"#\{1,2}\(\'[a-zA-ZæøåÆØÅ0-9,.:/ _&?%=\-\*]\+\'\|[a-zA-ZæøåÆØÅ0-9.:/_&?%=\-\*]\+\)" contains=WOIMcomment

" Reserved key words
syn keyword WOIMkey     END SKIP

" Marking literal start and end (a whole literal region is folded as one block)
syn match   WOIMlit     "\(\s\|\*\)\@<=\\$"

" Content of litaral (with no syntax highlighting)
syn match   WOIMlc      "\(\s\|\*\)\\\_.\{-}\(\s\|\*\)\\" contains=WOIMlit

" Comments are enclosed within ( )
syn match   WOIMcomment "(.\{-})" contains=WOIMtodo,WOIMref

" Text in quotation marks
syn match   WOIMquote   '".\{-}"' contains=WOIMtodo,WOIMref

" TODO  or FIXME
syn keyword WOIMtodo    TODO FIXME						

" Item motion
syn match   WOIMmove    ">>\|<<\|->\|<-"

" Bold and Italic
syn match   WOIMb	" \@<=\*.\{-}\* "
syn match   WOIMi	" \@<=/.\{-}/ "
syn match   WOIMu	" \@<=_.\{-}_ "

" State & Transitions
syn match   WOIMstate	"\(\(\s\|\*\)S: \)\@<=[^;]*" contains=WOIMtodo,WOIMop,WOIMcomment,WOIMref,WOIMqual,WOIMsc,WOIMmove,WOIMtag,WOIMquote
syn match   WOIMtrans	"\(\(\s\|\*\)T: \)\@<=[^;]*" contains=WOIMtodo,WOIMop,WOIMcomment,WOIMref,WOIMqual,WOIMsc,WOIMmove,WOIMtag,WOIMquote

" Cluster the above
syn cluster WOIMtxt contains=WOIMident,WOIMmulti,WOIMop,WOIMqual,WOIMtag,WOIMref,WOIMkey,WOIMlit,WOIMlc,WOIMcomment,WOIMquote,WOIMsc,WOIMtodo,WOIMmove,WOIMb,WOIMi,WOIMu,WOIMstate,WOIMtrans

" WOIM indentation (folding levels) {{{2
syn region L15 start="^\(\t\|\*\)\{14} \=\S" end="^\(^\(\t\|\*\)\{15,} \=\S\)\@!" fold contains=@WOIMtxt
syn region L14 start="^\(\t\|\*\)\{13} \=\S" end="^\(^\(\t\|\*\)\{14,} \=\S\)\@!" fold contains=@WOIMtxt,L15
syn region L13 start="^\(\t\|\*\)\{12} \=\S" end="^\(^\(\t\|\*\)\{13,} \=\S\)\@!" fold contains=@WOIMtxt,L14,L15
syn region L12 start="^\(\t\|\*\)\{11} \=\S" end="^\(^\(\t\|\*\)\{12,} \=\S\)\@!" fold contains=@WOIMtxt,L13,L14,L15
syn region L11 start="^\(\t\|\*\)\{10} \=\S" end="^\(^\(\t\|\*\)\{11,} \=\S\)\@!" fold contains=@WOIMtxt,L12,L13,L14,L15
syn region L10 start="^\(\t\|\*\)\{9} \=\S"  end="^\(^\(\t\|\*\)\{10,} \=\S\)\@!" fold contains=@WOIMtxt,L11,L12,L13,L14,L15
syn region L9 start="^\(\t\|\*\)\{8} \=\S"   end="^\(^\(\t\|\*\)\{9,} \=\S\)\@!"  fold contains=@WOIMtxt,L10,L11,L12,L13,L14,L15
syn region L8 start="^\(\t\|\*\)\{7} \=\S"   end="^\(^\(\t\|\*\)\{8,} \=\S\)\@!"  fold contains=@WOIMtxt,L9,L10,L11,L12,L13,L14,L15
syn region L7 start="^\(\t\|\*\)\{6} \=\S"   end="^\(^\(\t\|\*\)\{7,} \=\S\)\@!"  fold contains=@WOIMtxt,L8,L9,L10,L11,L12,L13,L14,L15
syn region L6 start="^\(\t\|\*\)\{5} \=\S"   end="^\(^\(\t\|\*\)\{6,} \=\S\)\@!"  fold contains=@WOIMtxt,L7,L8,L9,L10,L11,L12,L13,L14,L15
syn region L5 start="^\(\t\|\*\)\{4} \=\S"   end="^\(^\(\t\|\*\)\{5,} \=\S\)\@!"  fold contains=@WOIMtxt,L6,L7,L8,L9,L10,L11,L12,L13,L14,L15
syn region L4 start="^\(\t\|\*\)\{3} \=\S"   end="^\(^\(\t\|\*\)\{4,} \=\S\)\@!"  fold contains=@WOIMtxt,L5,L6,L7,L8,L9,L10,L11,L12,L13,L14,L15
syn region L3 start="^\(\t\|\*\)\{2} \=\S"   end="^\(^\(\t\|\*\)\{3,} \=\S\)\@!"  fold contains=@WOIMtxt,L4,L5,L6,L7,L8,L9,L10,L11,L12,L13,L14,L15
syn region L2 start="^\(\t\|\*\)\{1} \=\S"   end="^\(^\(\t\|\*\)\{2,} \=\S\)\@!"  fold contains=@WOIMtxt,L3,L4,L5,L6,L7,L8,L9,L10,L11,L12,L13,L14,L15
syn region L1 start="^\S"                    end="^\(^\(\t\|\*\)\{1,} \=\S\)\@!"  fold contains=@WOIMtxt,L2,L3,L4,L5,L6,L7,L8,L9,L10,L11,L12,L13,L14,L15

" VIM parameters (VIM modeline) {{{2
syn match   WOIMvim "^vim:.*"

" Highlighting and Linking {{{1
hi	    Folded	ctermfg=yellow ctermbg=none guibg=NONE guifg=darkyellow gui=bold
hi	    L1		gui=bold term=bold cterm=bold
hi def link WOIMident	Define
hi def link WOIMmulti	String
hi def link WOIMop	Function
hi def link WOIMqual	Type
hi def link WOIMtag	String
hi def link WOIMref	Define
hi def link WOIMkey	Define
hi          WOIMlit     ctermfg=none ctermbg=none gui=italic term=italic cterm=italic
hi          WOIMlc      ctermfg=white ctermbg=none
hi def link WOIMcomment	Comment
hi def link WOIMquote	Comment
hi def link WOIMsc	Type
hi def link WOIMtodo	Todo
hi def link WOIMmove	Error
hi	    WOIMb	ctermfg=none ctermbg=none gui=bold term=bold cterm=bold
hi	    WOIMi	ctermfg=none ctermbg=none gui=italic term=italic cterm=italic
hi link	    WOIMu	underlined
hi link	    WOIMstate	underlined
hi def link WOIMvim     Function

" Keymap {{{1

if exists('g:WoimDisableMapping') && g:WoimDisableMapping
    finish
endif

map <leader>0	:set foldlevel=0<CR>
map <leader>1	:set foldlevel=1<CR>
map <leader>2	:set foldlevel=2<CR>
map <leader>3	:set foldlevel=3<CR>
map <leader>4	:set foldlevel=4<CR>
map <leader>5	:set foldlevel=5<CR>
map <leader>6	:set foldlevel=6<CR>
map <leader>7	:set foldlevel=7<CR>
map <leader>8	:set foldlevel=8<CR>
map <leader>9	:set foldlevel=9<CR>
map <leader>a	:set foldlevel=10<CR>
map <leader>b	:set foldlevel=11<CR>
map <leader>c	:set foldlevel=12<CR>
map <leader>d	:set foldlevel=13<CR>
map <leader>e	:set foldlevel=14<CR>
map <leader>f	:set foldlevel=15<CR>
map <SPACE>		za

map <leader>s	:hi link WOIMstate NONE<CR>
map <leader>S	:hi link WOIMstate underlined<CR>
map <leader>t	:hi link WOIMtrans NONE<CR>
map <leader>T	:hi link WOIMtrans underlined<CR>

map <leader>v	:call CheckItem("")<CR>
map <leader>V	:call CheckItem("stamped")<CR>

map <leader><SPACE>	/=\s*$<CR>A

map gr			:call GotoRef()<CR>

nmap g<DOWN>            <DOWN><leader>0zv
nmap g<UP>              <leader>f<UP><leader>0zv

nmap <leader><DOWN>     <DOWN><leader>0zv<SPACE>zO
nmap <leader><UP>       <leader>f<UP><leader>0zv<SPACE>zO

nmap <leader>z   V:!openssl bf -e -a -salt 2>/dev/null<CR><C-L>
vmap <leader>z   :!openssl bf -e -a -salt 2>/dev/null<CR><C-L>
nmap <leader>Z   :%!openssl bf -e -a -salt 2>/dev/null<CR><C-L>
nmap <leader>x   V:!openssl bf -d -a 2>/dev/null<CR><C-L>
vmap <leader>x   :!openssl bf -d -a 2>/dev/null<CR><C-L>
nmap <leader>X   :%!openssl bf -d -a 2>/dev/null<CR><C-L>

nmap <leader>L  :call LaTeXconversion()<CR>

" vim modeline {{{1
" vim: sw=4 sts=4 et fdm=marker fillchars=fold\:\ :

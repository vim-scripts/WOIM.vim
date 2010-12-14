" Vim syntax and filetype plugin for WOIM files (.woim)
" Language:		Self defined markup for WOIM lists in Vim
" Author:		Geir Isene <geir@isene.com>
" Web_site:		http://isene.com/
" WOIM_def:		http://isene.com/woim.pdf
" Version:		0.9.8 - compatible with WOIM v. 1.2
" Modified:		2010-12-14
"
" Changes since previous mod:
" Feature:		States (S:) is underlined by default.
"				<leader>s removes the underlining, while
"				<leader>S turns on underlining of States.
"				Transitions are not underlined by default.
"				<leader>T turns on underlining, while
"				<leader>t removes the underlining of Transitions.
" Fix:			Removed unnecessary "contained" to make lists syntax
"				marked even within stub lists.
" Fix:			Small fixes in grouping and containing of elements.
" 
"
" INSTRUCTIONS
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
" Use <leader><SPACE> to go to the next open template element
" (A template element is a WOIM item ending in an equal sign)
"
" Syntax updated at start and every time you leave Insert mode


" Initializing
if exists("b:current_syntax")
  finish
endif

if version < 600
  syntax clear
elseif exists("b:current_syntax")
  finish
endif

" Basics
let	b:current_syntax="WOIM"
set textwidth=0
set	shiftwidth=2
set	tabstop=2
set	softtabstop=2
set noexpandtab
set	foldmethod=syntax
set fillchars=fold:\ 
syn sync fromstart
autocmd InsertLeave * :syntax sync fromstart

" Identifier (any number in front)
syn	match	WOIMident	 "\(\t\|\*\)*[0-9.]\+\.\s"

" Multi-line
syn match	WOIMmulti	"^\(\t\|\*\)*+ "

" WOIM operators
syn	match	WOIMop		"[A-ZÆØÅ_/]\{-2,}:" contains=WOIMcomment

" Qualifiers are enclosed within [ ]
syn	match	WOIMqual	"\[.*\]" contains=WOIMtodo,WOIMref,WOIMcomment

" Tags - anything that ends in a colon
syn	match	WOIMtag '\(\s\|\*\)\@<=[a-zA-ZæøåÆØÅ0-9,._= \-\/+<>()#']\{-2,}:\s' contains=WOIMident,WOIMtodo,WOIMop,WOIMcomment,WOIMref,WOIMstate,WOIMtrans

" Mark semicolon as stringing together lines
syn match	WOIMsc		";"

" References start with a hash (#)
syn	match	WOIMref	"#\{1,2}\(\'[a-zA-ZæøåÆØÅ0-9.:/ _&?%=-\*]\+\'\|[a-zA-ZæøåÆØÅ0-9.:/_&?%=-\*]\+\)" contains=WOIMcomment

" Comments are enclosed within ( )
syn	match	WOIMcomment	"(\_.\{-})" contains=WOIMtodo,WOIMref

" Text in quotation marks
syn	match	WOIMquote	'"\_.\{-}"' contains=WOIMtodo,WOIMref

" TODO  or FIXME
syn	keyword WOIMtodo	TODO FIXME						

" Item motion
syn match	WOIMmove	">>\|<<\|->\|<-"

" Bold and Italic
syn	match   WOIMb		" \@<=\*.\{-}\* "
syn	match   WOIMi		" \@<=/.\{-}/ "
syn	match   WOIMu		" \@<=_.\{-}_ "

" State & Transitions
syn match	WOIMstate	"\([.* \t]S: \)\@<=[^;]*" contains=WOIMtodo,WOIMop,WOIMcomment,WOIMref,WOIMqual,WOIMsc,WOIMmove,WOIMtag,WOIMquote
syn match	WOIMtrans	"\([.* \t]T: \)\@<=[^;]*" contains=WOIMtodo,WOIMop,WOIMcomment,WOIMref,WOIMqual,WOIMsc,WOIMmove,WOIMtag,WOIMquote

" Cluster the above
syn cluster WOIMtxt contains=WOIMident,WOIMmulti,WOIMop,WOIMqual,WOIMtag,WOIMref,WOIMcomment,WOIMquote,WOIMsc,WOIMtodo,WOIMmove,WOIMb,WOIMi,WOIMu,WOIMstate,WOIMtrans

" Levels
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

" Folds
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

" Highlighting and Linking :
hi				Folded			ctermfg=yellow ctermbg=none
hi				L1				gui=bold term=bold cterm=bold
hi def link		WOIMident		Define
hi def link		WOIMmulti		String
hi def link		WOIMop			Function
hi def link		WOIMqual		Type
hi def link		WOIMtag			String
hi def link		WOIMref			Define
hi def link		WOIMcomment		Comment
hi def link		WOIMquote		Comment
hi def link		WOIMsc			Type
hi def link		WOIMtodo		Todo
hi def link		WOIMmove		Error
hi				WOIMb			ctermfg=none ctermbg=none gui=bold term=bold cterm=bold
hi				WOIMi			ctermfg=none ctermbg=none gui=italic term=italic cterm=italic
hi link			WOIMu			underlined
hi link			WOIMstate		underlined

" VIM parameters
syn	match		WOIMvim			"^vim:.*"
hi def link		WOIMvim			Function

" macros
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

map <leader><SPACE>	/=\s*$<CR>A

" vim: ts=4

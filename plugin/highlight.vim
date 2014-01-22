" File: highlight.vim
" Author: Dewdrops <v_v_4474@126.com>
" Version: 0.1
" Last Modified: Tue Apr 12 15:18:16 IST 2011
" Description: Highlight current word or certain pattern
" Uasge:
"     <leader>hl   Toggle highlight word under cursor
"     <leader>hp   Toggle highlight pattern
"     <leader>/    Clear all highlights
"
"   All above commands work in both normal & insert modes.
"   <C-h><C-h> also works in visual mode. (Select desired lines & hit <C-h><C-h>)
"
" Installation:
"   Copy highlight-current-word.vim to your .vim/plugin directory
"
" Configuration:
"   To define custom colors set the following variables
"     g:pcolor_bg - Background color for word highlighting
"     g:pcolor_fg - Foreground color for word highlighting
"
" Acknowledgement:
"   Based on Amit Sethi(<amitrajsethi@yahoo.com>)'s highlight.vim
"   (https://github.com/vim-scripts/highlight.vim)
"


if exists("loaded_highlight")
   finish
endif
let loaded_highlight = ""

syntax on

" -- Mappings --

" TODO: implement disable
" Toggle highlight word under cursor
nnoremap  <silent> <leader>hl :call <SID>Highlight("w") \| nohls<CR>
" Toggle highlight pattern
nnoremap  <silent> <leader>hl :call <SID>Highlight("w") \| nohls<CR>
" Clear all highlights
nnoremap  <silent> <leader>/ :call <SID>Highlight("n") \| nohls<CR>


" Define colors for highlight
if !exists('g:pcolor_bg')
   let g:pcolor_bg = "yellow,blue,green,magenta,cyan,brown,orange,red"
endif

if !exists('g:pcolor_fg')
   let g:pcolor_fg = "black,white,black,white,black,white,black,white"
endif

if !exists('g:pcolor_bg_cterm')
   let g:pcolor_bg_cterm = "DarkBlue,DarkGreen,DarkCyan,DarkRed,Yellow,Magenta,Brown,LightGray"
endif

if !exists('g:pcolor_fg_cterm')
   let g:pcolor_fg_cterm = "White,Black,White,White,White,White,Black,Black"
endif


" Highlight: Highlight word
function! <SID>Highlight(mode)

   let cur_word = expand("<cword>")

   " Word mode
   if a:mode == 'w'
      let s:pcolor_n = s:pcolor_n == s:pcolor_max - 1 ?  1 : s:pcolor_n + 1
      exec 'syn match ' . s:pcolor_grp . s:pcolor_n . ' "\<' . cur_word . '\>" containedin=ALL'
   endif

   " Clean all
   if a:mode == 'n'
      let ccol = 0
      while ccol < s:pcolor_max
         exec 'syn clear '. s:pcolor_grp . ccol
         let ccol = ccol + 1
      endw

      let s:pcolor_n = 0
   endif

endfunction


" Strntok: Utility function to implement C-like strntok() by Michael Geddes
" and Benji Fisher at http://groups.yahoo.com/group/vimdev/message/26788
function! s:Strntok( s, tok, n)
    return matchstr( a:s.a:tok[0], '\v(\zs([^'.a:tok.']*)\ze['.a:tok.']){'.a:n.'}')
endfun

" ItemCount: Returns the number of items in the given string.
" Developed by Dan Sharp in MultipleSearch2.vim at
" http://www.vim.org/scripts/script.php?script_id=1183
function! s:ItemCount(string)
    let itemCount = 0
    let newstring = a:string
    let pos = stridx(newstring, ',')
    while pos > -1
        let itemCount = itemCount + 1
        let newstring = strpart(newstring, pos + 1)
        let pos = stridx(newstring, ',')
    endwhile
    return itemCount
endfunction

" Min: Returns the minimum of the given parameters.
" Developed by Dan Sharp in MultipleSearch2.vim at
" http://www.vim.org/scripts/script.php?script_id=1183
function! s:Min(...)
    let min = a:1
    let index = 2
    while index <= a:0
        execute "if min > a:" . index . " | let min = a:" . index . " | endif"
        let index = index + 1
    endwhile
    return min
endfunction

" HighlightInitP: Initialize the highlight groups for line highlight
" Based on 'MultipleSearchInit' function developed by Dan Sharp in
" MultipleSearch2.vim at http://www.vim.org/scripts/script.php?script_id=1183
function! s:HighlightInitP()
   let s:pcolor_grp = "PHiColor"
   let s:pcolor_n = 0

   let s:pcolor_max = s:Min(s:ItemCount(g:pcolor_bg . ','), s:ItemCount(g:pcolor_fg . ','))

   let ci = 0
   while ci < s:pcolor_max
      let bgColor = s:Strntok(g:pcolor_bg, ',', ci + 1)
      let fgColor = s:Strntok(g:pcolor_fg, ',', ci + 1)
      let bgColor_cterm = s:Strntok(g:pcolor_bg_cterm, ',', ci + 1)
      let fgColor_cterm = s:Strntok(g:pcolor_fg_cterm, ',', ci + 1)

      exec 'hi ' . s:pcolor_grp . ci .
         \ ' guifg =' . fgColor . ' guibg=' . bgColor
         \ ' ctermfg =' . fgColor_cterm . ' ctermbg=' . bgColor_cterm

      let ci = ci + 1
   endw
endfunction


call s:HighlightInitP()


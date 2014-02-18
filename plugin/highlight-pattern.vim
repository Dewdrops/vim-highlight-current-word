" File: vim-highlight-pattern.vim
" Author: Dewdrops <v_v_4474@126.com>
" Version: 0.1
" Last Modified: Tue Apr 12 15:18:16 IST 2011
" Description: Highlight current word or certain pattern
" Uasge:
"     <leader>hl   Toggle highlight word under cursor (or text in the region
"     if in visual mode)
"     <leader>hp   Highlight pattern
"     <leader>/    Clear all highlights
"
" Installation:
"   Copy vim-highlight-pattern.vim to your .vim/plugin directory
"
" Configuration:
"   To define custom colors set the following variables
"     g:pcolor_bg - Background color for highlight in gui
"     g:pcolor_fg - Foreground color for highlight in gui
"     g:pcolor_bg_cterm - Background color for highlight in term
"     g:pcolor_fg_cterm - Foreground color for highlight in term
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

nmap  <silent> <Plug>(VHP_HighlightWordToggle) :call VHP_HighlightWordToggle() \| nohls<CR>
vmap  <silent> <Plug>(VHP_HighlightRegionToggle) :call VHP_HighlightRegionToggle() \| nohls<CR>
nmap  <silent> <Plug>(VHP_HighlightPattern) :call VHP_HighlightPattern() \| nohls<CR>
nmap  <silent> <Plug>(VHP_HighlightClear) :call VHP_HighlightClear() \| nohls<CR>

" Toggle highlight word under cursor
if !hasmapto('<Plug>(VHP_HighlightWordToggle)')
    nmap  <silent> <leader>hl <Plug>(VHP_HighlightWordToggle)
endif
" Toggle highlight text depend on text in the region
if !hasmapto('<Plug>(VHP_HighlightRegionToggle)')
    vmap  <silent> <leader>hl <Plug>(VHP_HighlightRegionToggle)
endif
" Highlight pattern
if !hasmapto('<Plug>(VHP_HighlightPattern)')
    nmap  <silent> <leader>hp <Plug>(VHP_HighlightPattern)
endif
" Clear all highlights
if !hasmapto('<Plug>(VHP_HighlightClear)')
    nmap  <silent> <leader>/ <Plug>(VHP_HighlightClear)
endif


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


" Highlight: Toggle highlight word
function! VHP_HighlightWordToggle()
    if !exists("b:pcolor_n") | let b:pcolor_n = 0 | endif
    if !exists("b:colored_words") | let b:colored_words = [] | endif

    let cur_word = expand("<cword>")
    let idx = 0
    while idx < len(b:colored_words)
        let it = b:colored_words[idx]
        if it[0] == cur_word
            exec 'syn clear '. it[1]
            call remove(b:colored_words, idx)
            return
        endif
        let idx = idx + 1
    endwhile
    let b:pcolor_n = b:pcolor_n == s:pcolor_max - 1 ?  1 : b:pcolor_n + 1
    call add(b:colored_words, [cur_word, s:pcolor_grp . b:pcolor_n])
    exec 'syn match ' . s:pcolor_grp . b:pcolor_n . ' "\<' . cur_word . '\>" containedin=ALL'
endfunction

" Highlight: Toggle highlight region
function! VHP_HighlightRegionToggle()
    if !exists("b:pcolor_n") | let b:pcolor_n = 0 | endif
    if !exists("b:colored_words") | let b:colored_words = [] | endif

    let reg = '"'
    let [save_reg, save_type] = [getreg(reg), getregtype(reg)]
    normal! gvy
    let text = @"
    call setreg(reg, save_reg, save_type)
    let idx = 0
    while idx < len(b:colored_words)
        let it = b:colored_words[idx]
        if it[0] == text
            exec 'syn clear '. it[1]
            call remove(b:colored_words, idx)
            return
        endif
        let idx = idx + 1
    endwhile
    let b:pcolor_n = b:pcolor_n == s:pcolor_max - 1 ?  1 : b:pcolor_n + 1
    call add(b:colored_words, [text, s:pcolor_grp . b:pcolor_n])
    exec 'syn match ' . s:pcolor_grp . b:pcolor_n . ' "' . text . '" containedin=ALL'
endfunction

" Highlight: Highlight pattern
function! VHP_HighlightPattern()
    if !exists("b:pcolor_n") | let b:pcolor_n = 0 | endif

    let pat = input("Pattern: ")
    let b:pcolor_n = b:pcolor_n == s:pcolor_max - 1 ?  1 : b:pcolor_n + 1
    exec 'syn match ' . s:pcolor_grp . b:pcolor_n . ' "\<' . pat . '\>" containedin=ALL'
endfunction


function! VHP_HighlightClear()
    " Clean all
    let ccol = 0
    while ccol < s:pcolor_max
        exec 'syn clear '. s:pcolor_grp . ccol
        let ccol = ccol + 1
    endw

    if exists("b:pcolor_n") | let b:pcolor_n = 0 | endif
    if exists("b:colored_words") | let b:colored_words = [] | endif
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
function! s:HighlightInit()
   let s:pcolor_grp = "VHiPColor"

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


call s:HighlightInit()


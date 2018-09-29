" printf.vim - Turn lines into printf statements
" Maintainer: Anton Lindqvist <anton@basename.se>
" Version:    0.4.4

if exists('g:loaded_printf')
  finish
endif
let g:loaded_printf = 1

" Enable line continuation.
let s:save_cpo = &cpo
set cpo&vim

" Returns the Number 1 if {str} contains an even number of opening/closing
" pairs of parentheses and brackets.
function! s:Balanced(str) abort
  let pairs = {
        \ '()': 0,
        \ '[]': 0,
        \ }

  for i in range(len(a:str))
    if a:str[i] ==# '('
      let pairs['()'] += 1
    elseif a:str[i] ==# ')'
      let pairs['()'] -= 1
    elseif a:str[i] ==# '['
      let pairs['[]'] += 1
    elseif a:str[i] ==# ']'
      let pairs['[]'] -= 1
    endif
  endfor

  return pairs['()'] == 0 && pairs['[]'] == 0
endfunction

function! s:Escape(str, chars) abort
  let s = substitute(a:str, '\(%\|\\\)', '&&', 'g')
  let s = escape(s, a:chars)

  return s
endfunction

function! s:ParsePattern() abort
  let pattern = getbufvar('%', 'printf_pattern', 'printf("%d\n", %s);')
  let dirpat = '[^%]\zs%\(\w\|\.\|+\)\+'
  let directive = matchstr(pattern, dirpat)
  let parts = map(
        \ split(pattern, dirpat, 1),
        \ 'substitute(v:val, "%%", "%", "")')

  return {'prefix':    parts[0],
        \ 'middle':    parts[1],
        \ 'suffix':    parts[2],
        \ 'directive': directive,
        \ 'separator': '='}
endfunction

function! s:Split(str) abort
  let str = a:str
  let parts = []
  let i = 0

  while i < len(str)
    let i = match(str, ',', i)
    if i < 0
      let i = len(str) " trailing part
    endif
    if s:Balanced(str[:i])
      " A valid token must contain at least one character other than
      " whitespace and comma. Otherwise, discard the found substring.
      if match(str[:i], '^\(\s\|,\)\+$') == -1
        call add(parts, substitute(str[:i - 1], '^\s\+', '', ''))
      endif
      let str = str[i + 1:]
      let i = 0
    else
      let i += 1 " move past found comma
    endif
  endwhile

  return parts
endfunction

function! s:PrintfUndo() abort
  let pat = s:ParsePattern()
  let line = getline('.')

  let i = stridx(line, pat.prefix)
  if i == -1 | return 0 | endif
  let i += len(pat.prefix)

  let i = stridx(line, pat.middle, i)
  if i == -1 | return 0 | endif
  let i += len(pat.middle)

  let j = strridx(line, pat.suffix)
  if j == -1 | return 0 | endif

  let indent = matchstr(line, '^\s\+')
  call setline('.', indent . line[i:j - 1])
  " Move to the first token.
  normal! ^

  return 1
endfunction

function! s:Printf() abort
  if s:PrintfUndo() | return | endif

  let pat = s:ParsePattern()

  " If the directive is wrapped in string quotes, escape the quote character.
  let esc = ''
  if match(pat.prefix, '"') >= 0 | let esc .= '"' | endif
  if match(pat.prefix, "'") >= 0 | let esc .= "'" | endif

  let indent = matchstr(getline('.'), '^\s\+')
  let line = substitute(getline('.'), indent, '', '')
  if len(line) == 0 | return | endif

  let tokens = s:Split(line)
  if len(tokens) == 0 | return | endif
  let format = join(
        \ map(tokens, 's:Escape(v:val, esc) . pat.separator . pat.directive'),
        \ ', ')

  call setline('.',
        \ indent . pat.prefix . format . pat.middle . line . pat.suffix)

  " Move the cursor to the first directive.
  " Make sure to skip past the pattern prefix and left-hand side of the first
  " token since they may include percent literals.
  let off = stridx(tokens[0], pat.separator)
  if off < 0 | let off = 0 | endif
  let off += len(pat.prefix)
  execute 'normal! ^' . off . 'lf%'
endfunction

command! Printf call s:Printf()

let &cpo = s:save_cpo

" printf.vim - Turn lines into printf statements
" Maintainer: Anton Lindqvist <anton.lindqvist@gmail.com>
" Version:    0.3.1

if exists('g:loaded_printf')
  finish
endif
let g:loaded_printf = 1

" Enable line continuation.
let s:save_cpo = &cpo
set cpo&vim

function! s:Balanced(str, l, r) abort
  let n = 0

  for i in range(len(a:str))
    if a:str[i] == a:l
      let n += 1
    elseif a:str[i] == a:r
      let n -= 1
    endif
  endfor

  return n == 0
endfunction

function! s:Escape(str, chars) abort
  let s = escape(a:str, a:chars)
  let s = substitute(s, '%', '&&', 'g')

  return s
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
    if s:Balanced(str[:i], '(', ')') && s:Balanced(str[:i], '[', ']')
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

function! s:Printf() abort
  let pattern = getbufvar('%', 'printf_pattern', 'printf("%d\n", %s);')
  let directive = matchstr(pattern, '[^%]\zs%\(\w\|\.\)\+')

  let [prefix, middle, suffix] = map(
        \ split(pattern, '[^%]\zs%\(\w\|\.\)\+', 1),
        \ 'substitute(v:val, "%%", "%", "")')

  " If the directive is wrapped in string quotes, escape the quote character.
  let esc = ''
  if match(prefix, '"') >= 0 | let esc .= '"' | endif
  if match(prefix, "'") >= 0 | let esc .= "'" | endif

  let indent = matchstr(getline('.'), '^\s\+')
  let line = substitute(getline('.'), indent, '', '')
  if len(line) == 0 | return | endif

  let tokens = s:Split(line)
  if len(tokens) == 0 | return | endif
  let format = join(
        \ map(tokens, 's:Escape(v:val, esc) . "=" . directive'), ', ')

  call setline('.', indent . prefix . format . middle . line . suffix)
  " Move the cursor to the first directive. Make sure to skip past the pattern
  " prefix since it may include percent literals.
  execute 'normal! ^' . len(prefix) . 'lf%'
endfunction

command! Printf call s:Printf()

let &cpo = s:save_cpo

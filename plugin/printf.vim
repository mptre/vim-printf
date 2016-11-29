" printf.vim - Turn lines into printf statements
" Maintainer: Anton Lindqvist <anton.lindqvist@gmail.com>
" Version:    0.1.0

if exists('g:loaded_printf')
  finish
endif
let g:loaded_printf = 1

function! s:balanced(str, l, r) abort
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

function! s:split(str) abort
  let str = a:str
  let parts = []
  let i = 0

  while i < len(str)
    let i = match(str, ',', i)
    if i < 0
      let i = len(str) " trailing part
    endif
    if s:balanced(str[:i], '(', ')') && s:balanced(str[:i], '[', ']')
      call add(parts, substitute(str[:i - 1], '^\s\+', '', ''))
      let str = str[i + 1:]
      let i = 0
    else
      let i += 1 " move past found comma
    endif
  endwhile

  return parts
endfunction

function! s:printf() abort
  let pattern = getbufvar('%', 'printf_pattern')
  if empty(pattern) | let pattern = 'printf("%d\n", %s);' | endif
  let directive = matchstr(pattern, '%\(\w\|\.\)\+')

  let [prefix, middle, suffix] = split(pattern, '%\(\w\|\.\)\+', 1)

  " If the directive is wrapped in string quotes, escape the quote character.
  let esc = ''
  if match(prefix, '"') >= 0 | let esc .= '"' | endif
  if match(prefix, "'") >= 0 | let esc .= "'" | endif

  let indent = matchstr(getline('.'), '^\s\+')
  let line = substitute(getline('.'), indent, '', '')
  if len(line) == 0 | return | endif
  let format = join(map(s:split(line), 'escape(v:val, esc) . "=" . directive'), ', ')
  call setline('.', indent . prefix . format . middle . line . suffix)
  normal! ^f%
endfunction

command! Printf call s:printf()

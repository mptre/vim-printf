if exists('g:loaded_printf')
  finish
endif
let g:loaded_printf = 1

function! s:balancedparens(str) abort
  let n = 0

  for i in range(len(a:str))
    if a:str[i] == '('
      let n += 1
    elseif a:str[i] == ')'
      let n -= 1
    endif
  endfor

  return n == 0
endfunc

function! s:split(str) abort
  let str = a:str
  let parts = []
  let i = 0

  while len(str) > 0
    let i = match(str, ',', i)
    if i < 0
      let i = len(str) " trailing part
    endif
    if s:balancedparens(str[:i])
      call add(parts, substitute(str[:i - 1], '^\s\+', '', ''))
      let str = str[i + 1:]
      let i = 0
    else
      let i += 1 " move past found comma
    endif
  endwhile

  return parts
endfunc

function! s:printf() abort
  let pattern = getbufvar('%', 'printf_pattern')
  if empty(pattern) | let pattern = 'printf("%d\n", %s);' | endif
  let directive = matchstr(pattern, '%\(\w\|\.\)\+')

  let [prefix, middle, suffix] = split(pattern, '%\(\w\|\.\)\+', 1)
  let indent = matchstr(getline('.'), '^\s\+')
  let line = substitute(getline('.'), indent, '', '')
  if len(line) == 0 | return | endif
  let format = join(map(s:split(getline('.')), 'v:val . "=" . directive'), ', ')
  call setline('.', indent . prefix . format . middle . line . suffix)
  normal! ^f%
endfunc

nnoremap <silent> <Plug>Printf :call <SID>printf()<CR>
command! Printf call s:printf()

if !exists('g:no_plugin_maps') && !exists('g:no_printf_maps')
  nmap <Leader>p <Plug>Printf
endif

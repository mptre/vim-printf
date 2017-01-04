" Enable line continuation.
set nocp

function! s:test(line, exp, ...) abort
  new
  if a:0 > 0 | let b:printf_pattern = a:1 | endif
  call setline(1, [a:line])
  try
    Printf
  catch
    call add(v:errors, v:throwpoint . ': ' . v:exception)
    return
  endtry
  call assert_equal(a:exp, getline('.'))
  quit!
endfunction

call s:test('',
          \ '')

call s:test('x',
          \ 'printf("x=%d\n", x);')

call s:test('  x',
          \ '  printf("x=%d\n", x);')

call s:test('x, y',
          \ 'printf("x=%d, y=%d\n", x, y);')

call s:test('x,y',
          \ 'printf("x=%d, y=%d\n", x,y);')

call s:test('x % y',
          \ 'printf("x %% y=%d\n", x % y);')

call s:test('x(1, y(2, 3)), z(4)',
          \ 'printf("x(1, y(2, 3))=%d, z(4)=%d\n", x(1, y(2, 3)), z(4));')

call s:test('x[1, 2]',
          \ 'printf("x[1, 2]=%d\n", x[1, 2]);')

call s:test('strlen("x")',
          \ 'printf("strlen(\"x\")=%d\n", strlen("x"));')

call s:test('len("x")',
          \ 'echom printf("len(\"x\")=%s", len("x"))',
          \ 'echom printf("%s", %s)')

call s:test('len(''x'')',
          \ 'echom printf(''len(\''x\'')=%s'', len(''x''))',
          \ 'echom printf(''%s'', %s)')

call s:test('x, y',
          \ 'echom printf("x=%s, y=%s", x, y)',
          \ 'echom printf("%s", %s)')

call s:test('x',
          \ 'printf("x=%.2f\n", x);',
          \ 'printf("%.2f\n", %s);')

if len(v:errors) > 0
  call writefile(v:errors, "/dev/stderr")
  cquit!
else
  qall!
end

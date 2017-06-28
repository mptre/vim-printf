" Enable line continuation.
set cpo&vim

function XTest_Setup(line, ...)
  new
  if a:0 > 0 | let b:printf_pattern = a:1 | endif
  call setline(1, [a:line])
  Printf
endfunction

function Test_Empty()
  call XTest_Setup('')
  call assert_equal('', getline('.'))
endfunction

function Test_OnlyComma()
  call XTest_Setup(',')
  call assert_equal(',', getline('.'))
endfunction

function Test_OnlyCommasAndWhitespace()
  call XTest_Setup(', ,,  ,')
  call assert_equal(', ,,  ,', getline('.'))
endfunction

function Test_One()
  call XTest_Setup('x')
  call assert_equal('printf("x=%d\n", x);', getline('.'))
  call assert_equal(11, col('.'))
endfunction

function Test_Two()
  call XTest_Setup('x, y')
  call assert_equal('printf("x=%d, y=%d\n", x, y);', getline('.'))
endfunction

function Test_TwoNoSpace()
  call XTest_Setup('x,y')
  call assert_equal('printf("x=%d, y=%d\n", x,y);', getline('.'))
endfunction

function Test_PreserveIndent()
  call XTest_Setup('  x')
  call assert_equal('  printf("x=%d\n", x);', getline('.'))
endfunction

function Test_EscapePercentInToken()
  call XTest_Setup('x % y')
  call assert_equal('printf("x %% y=%d\n", x % y);', getline('.'))
endfunction

function Test_BalancedParens()
  call XTest_Setup('x(1, y(2, 3)), z(4)')
  call assert_equal(
        \ 'printf("x(1, y(2, 3))=%d, z(4)=%d\n", x(1, y(2, 3)), z(4));',
        \ getline('.'))
endfunction

function Test_BalancedBrackets()
  call XTest_Setup('x[1, 2]')
  call assert_equal('printf("x[1, 2]=%d\n", x[1, 2]);', getline('.'))
endfunction

function Test_EscapeDoubleQuotes()
  call XTest_Setup('strlen("x")')
  call assert_equal(
        \ 'printf("strlen(\"x\")=%d\n", strlen("x"));',
        \ getline('.'))
endfunction

function Test_EscapeSingleQuotes()
  call XTest_Setup('len(''x'')', 'echom printf(''%s'', %s)')
  call assert_equal(
        \ 'echom printf(''len(\''x\'')=%s'', len(''x''))',
        \ getline('.'))
endfunction

function Test_EscapePercentInPattern()
  call XTest_Setup('x', 'printf("%%s: %d\n", __func__, %s);')
  call assert_equal('printf("%s: x=%d\n", __func__, x);', getline('.'))
  call assert_equal(15, col('.'))
endfunction

function Test_EscapeBackslashInPattern()
  call XTest_Setup('sizeof("\000")')
  call assert_equal('printf("sizeof(\"\\000\")=%d\n", sizeof("\000"));', getline('.'))
endfunction

function Test_DotDirective()
  call XTest_Setup('x', 'printf("%.2f\n", %s);')
  call assert_equal('printf("x=%.2f\n", x);', getline('.'))
endfunction

function Test_Undo()
  call XTest_Setup('printf("x=%d\n", x);')
  call assert_equal('x', getline('.'))
  call assert_equal(1, col('.'))
endfunction

function Test_UndoIndent()
  call XTest_Setup('  printf("x=%d\n", x);')
  call assert_equal('  x', getline('.'))
  call assert_equal(3, col('.'))
endfunction

function Test_UndoTrailing()
  call XTest_Setup('printf("x=%d\n", x);  ')
  call assert_equal('x', getline('.'))
  call assert_equal(1, col('.'))
endfunction

redir @q
silent function /^Test_/
redir END
let tests = split(substitute(@q, 'function \(\k*()\)', '\1', 'g'))
for t in tests
  execute 'call ' . t
  quit!
endfor
if len(v:errors) > 0
  call writefile(v:errors, "/dev/stderr")
  cquit!
else
  qall!
end

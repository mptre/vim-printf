vim-printf
==========

Turn a line consisting of tokens separated by commas into a printf statement.
A token is recognized as a sequence of any characters expect for whitespace and
comma but with respect to balanced brackets and parentheses.
Examples showing the line before and after invoking `<Leader>p`:

| Before      | After                                  |
|:------------|:---------------------------------------|
| `x`         | `printf("x=%d\n", x);`                 |
| `x, x/y`    | `printf("x=%d, x/y=%d\n", x, x/y);`    |
| `pow(x, y)` | `printf("pow(x, y)=%d\n", pow(x, y));` |

The pattern used, specified by `b:printf_pattern`, can be altered for a given
filetype:

```vim
autocmd FileType vim let b:printf_pattern = 'echom printf("%s", %s)'
```

See the [documentation] for further reference on how the pattern is interpreted.

Installation
------------

Use the package feature introduced in Vim 8.0 or do what you did for the other
plugins you have installed.

FAQ
---

> The default pattern doesn't work for filetype X

Use the method described above to specify the pattern for a given filetype.
Below is a table of sensible patterns for different filetypes:

| Filetype | Pattern                                   |
|:---------|:------------------------------------------|
| c        | `fprintf(stderr, __FILE__ ": %d\n", %s);` |
| go       | `fmt.Printf("%v\n", %s)`                  |
| ruby     | `printf("%p\n", %s)`                      |
| vim      | `echom printf("%s", %s)`                  |

[documentation]: doc/printf.txt

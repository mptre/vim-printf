vim-printf
==========

Turn a line consisting of tokens separated by commas into a printf statement.
A token is recognized as a sequence of any characters expect for whitespace and
comma but with respect to balanced brackets and parentheses.
Examples showing the line before and after invoking `:Printf`:

| Before      | After                                  |
|:------------|:---------------------------------------|
| `x`         | `printf("x=%d\n", x);`                 |
| `x, x/y`    | `printf("x=%d, x/y=%d\n", x, x/y);`    |
| `pow(x, y)` | `printf("pow(x, y)=%d\n", pow(x, y));` |

Installation
------------

Use the package feature introduced in Vim 8.0 or do what you did for the other
plugins you have installed.

FAQ
---

> How do I change the pattern for a filetype?

The pattern used, specified by `b:printf_pattern`, can be altered for a given
filetype:

```vim
autocmd FileType vim let b:printf_pattern = 'echom printf("%s", %s)'
```

See the [documentation] for further reference on how the pattern is interpreted.

Below is a table of sensible patterns for different filetypes:

| Filetype | Pattern                                   |
|:---------|:------------------------------------------|
| c        | `fprintf(stderr, __FILE__ ": %d\n", %s);` |
| go       | `fmt.Printf("%v\n", %s)`                  |
| ruby     | `printf("%p\n", %s)`                      |
| vim      | `echom printf("%s", %s)`                  |

> How do I map the :Printf command to a key?

Add this to your vimrc and replace `<Leader>p` with your desired key:

```vim
nnoremap <Leader>p :Printf<CR>
```

[documentation]: doc/printf.txt

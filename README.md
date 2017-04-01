vim-printf
==========

![vim-printf](http://i.imgur.com/dSBEnuv.gif)

Turn a line consisting of tokens separated by commas into a printf statement.
A token is recognized as a sequence of any characters except for whitespace and
comma but with respect to balanced brackets and parentheses.
Examples showing the line before and after invoking `:Printf`:

| Before        | After                                        |
|:--------------|:---------------------------------------------|
| `x`           | `printf("x=%d\n", x);`                       |
| `x, x/y`      | `printf("x=%d, x/y=%d\n", x, x/y);`          |
| `pow(x, y)`   | `printf("pow(x, y)=%d\n", pow(x, y));`       |
| `strlen("x")` | `printf("strlen(\"x\")=%d\n", strlen("x"));` |

Installation
------------

Use the package feature introduced in Vim 8.0 or do what you did for the other
plugins you have installed.

FAQ
---

> How do I change the pattern for a filetype?

The pattern used, specified by `b:printf_pattern`, can be altered for a given
filetype.
Below is a list of sensible patterns for different filetypes:

```vim
autocmd FileType c    let b:printf_pattern = 'printf("%%s: %d\n", __func__, %s);'
autocmd FileType go   let b:printf_pattern = 'fmt.Printf("%v\n", %s)'
autocmd FileType java let b:printf_pattern = 'System.out.format("%d%%n", %s);'
autocmd FileType ruby let b:printf_pattern = 'printf("%p\n", %s)'
autocmd FileType vim  let b:printf_pattern = 'echom printf("%s", %s)'
```

See the [documentation] for further reference on how the pattern is interpreted.

> How do I map the :Printf command to a key?

Add this to your vimrc and replace `<Leader>p` with your desired key:

```vim
nnoremap <Leader>p :Printf<CR>
```

[documentation]: doc/printf.txt

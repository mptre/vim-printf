# vim-printf

![vim-printf](http://i.imgur.com/dSBEnuv.gif)

Turn a line consisting of tokens separated by commas into a printf statement.
A token is recognized as a sequence of any characters except for whitespace and
comma but with respect to balanced brackets and parentheses.

## Installation

Use the package feature introduced in Vim 8.0 or do what you did for the other
plugins you have installed.

## FAQ

> How do I change the pattern for a filetype?

The pattern used,
specified by `b:printf_pattern`,
can be altered for a given filetype.
Below is a list of sensible patterns for different filetypes.
If your favorite filetype is missing,
feel free to submit a pull request.

```vim
autocmd FileType awk  let b:printf_pattern = 'printf "%s\n", %s'
autocmd FileType c    let b:printf_pattern = 'printf("%%s: %d\n", __func__, %s);'
autocmd FileType go   let b:printf_pattern = 'fmt.Printf("%v\n", %s)'
autocmd FileType java let b:printf_pattern = 'System.out.format("%d%%n", %s);'
autocmd FileType ruby let b:printf_pattern = 'printf("%p\n", %s)'
autocmd FileType vim  let b:printf_pattern = 'echom printf("%s", %s)'
```

See the [documentation] for further reference on how the pattern is interpreted.

> How do I map the `:Printf` command to a key?

Add this to your vimrc and replace `<Leader>p` with your desired key:

```vim
nnoremap <Leader>p :Printf<CR>
```

## License

Copyright (c) Anton Lindqvist. Distributed under the MIT license.

[documentation]: doc/printf.txt

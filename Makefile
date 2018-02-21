VERSION=	0.4.4

all: test

release:
	@(for f in doc/printf.txt plugin/printf.vim; do \
		printf '/Version:\ns/\\([ \t]\\)[^ \t]*$$/\\1${VERSION}\nwq\n' \
			| ed $$f >/dev/null 2>&1; \
	done)

test:
	env TERM=dumb vim -n -u NONE \
		-c 'let g:test_filter = "${TEST_FILTER}"' \
		-S plugin/printf.vim -S tests/printf.vim

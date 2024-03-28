PREFIX := /usr

all: build install

build:
	gzip -c gdirel.1 > gdirel.1.gz

install:
	mkdir -vp $(PREFIX)/bin $(PREFIX)/share/man/man1
	install -vm 755 gdirel.sh $(PREFIX)/bin/gdirel
	cp -v gdirel.1.gz $(PREFIX)/share/man/man1

clean:
	rm -v gdirel.1.gz

.PHONY: all build install clean
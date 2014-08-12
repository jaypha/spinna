RDMD = rdmd

YUI = java -jar progs/yuicompressor-2.4.8.jar

SPINNA_ROOT = .

include makefile.include

BININSTALL = /usr/local/bin
LIBINSTALL = /usr/local/lib

LIBDIR = /usr/lib64/mysql
LIBS = fcgi fig mysqlclient
IMPDIR =  $(SPINNA_ROOT)/src

LIBFLAGS= $(addprefix -L-l,$(LIBS)) $(addprefix -L-L,$(LIBDIR))

JFLAGS = $(addprefix -J,$(IMPDIR))
IFLAGS = $(addprefix -I,$(IMPDIR))

DFLAGS = $(IFLAGS) $(JFLAGS)

RDFLAGS = $(DFLAGS) -release -O
DDFLAGS = $(DFLAGS) -g -debug

LFLAGS = $(LIBFLAGS)

build: bin lib js css

css: res/_spinna.scss res/_spinna_widgets.scss

js: res/spinna.js res/spinna_widgets.js

bin: bin/makerouter

# --------------------------

bin/makerouter: progs/makerouter.d lib/libfig.a
	$(RDMD) $(RDFLAGS) $(LFLAGS) -ofbin/makerouter --build-only progs/makerouter.d

# makerouter for testing

makerouter: progs/makerouter.d lib/libfig.a
	$(RDMD) $(DDFLAGS) $(LFLAGS) -ofmakerouter --build-only progs/makerouter.d

# --------------------------

lib: lib/libfig.a

lib/libfig.a:
	pushd fig; make lib
	cp fig/libfig.a lib

# --------------------------
# This is for installing support programs, not finished software.

install:
	cp bin/makerouter $(BININSTALL)
	strip $(BININSTALL)/makerouter
	cp lib/libfig.a $(LIBINSTALL)

# --------------------------

clean:
	rm -f makerouter
	rm -f bin/makerouter
	rm -f lib/libfig.a
	rm -f res/spinna.min.js
	rm -f res/spinna.js
	rm -f res/spinna.scss
	pushd fig; make clean


res/spinna.min.js: $(JSFILES)
	js -C $(addprefix -f ,$(JSFILES))
	$(YUI) $(JSFILES) -o res/spinna.min.js

res/spinna.js: $(JSFILES)
	js -C $(addprefix -f ,$(JSFILES))
	cat $(JSFILES) > res/spinna.js

res/spinna_widgets.js: $(JSWFILES)
	js -C $(addprefix -f ,$(JSWFILES))
	cat $(JSWFILES) > res/spinna_widgets.js

res/_spinna.scss:


res/_spinna_widgets.scss: $(SCSSFILES)
	cat $(SCSSFILES) > res/_spinna_widgets.scss

test:
	$(RDMD) $(DDFLAGS) $(LFLAGS) -J./src_test -unittest src_test/test_main.d

rpminstall: build
	rm -rf $(DESTDIR)/*
	mkdir $(DESTDIR)/usr
	mkdir $(DESTDIR)/usr/bin
	mkdir $(DESTDIR)/usr/lib64
	mkdir $(DESTDIR)/usr/include
	mkdir $(DESTDIR)/usr/include/spinna
	mkdir $(DESTDIR)/usr/include/spinna/src
	cp bin/makerouter $(DESTDIR)/usr/bin
	strip $(DESTDIR)/usr/bin/makerouter
	cp -R src/backtrace $(DESTDIR)/usr/include/spinna/src
	cp -R src/jaypha $(DESTDIR)/usr/include/spinna/src
	cp src/*.d $(DESTDIR)/usr/include/spinna/src
	cp -R thirdparty $(DESTDIR)/usr/include/spinna
	cp -R licenses $(DESTDIR)/usr/include/spinna
	cp -R res $(DESTDIR)/usr/include/spinna
	cp lib/libfig.a $(DESTDIR)/usr/lib64

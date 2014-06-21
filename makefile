RDMD = rdmd

YUI = java -jar progs/yuicompressor-2.4.8.jar

SPINNA_ROOT = .

include makefile.include

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

css: res/spinna.scss

js: res/spinna.js

bin: bin/makerouter bin/makefixdb

bin/makerouter: progs/makerouter.d lib/libfig.a
	$(RDMD) $(RDFLAGS) $(LFLAGS) -ofbin/makerouter --build-only progs/makerouter.d

bin/makefixdb: progs/makefixdb.d lib/libfig.a src/jaypha/fixdb/literal.d src/jaypha/fixdb/dbdef.d src/jaypha/fixdb/build.d
	$(RDMD) $(RDFLAGS) $(LFLAGS) -ofbin/makefixdb --build-only progs/makefixdb.d

# --------------------------
# makerouter for testing

makerouter: progs/makerouter.d lib/libfig.a
	$(RDMD) $(DDFLAGS) $(LFLAGS) -ofmakerouter --build-only progs/makerouter.d

# --------------------------

lib: lib/libfig.a

lib/libfig.a:
	pushd progs/fig; make lib
	cp progs/fig/libfig.a lib

# --------------------------
# This is for installing support programs, not finished software.

install:
	cp bin/makerouter /usr/local/bin
	strip /usr/local/bin/makerouter
	cp bin/makefixdb /usr/local/bin
	strip /usr/local/bin/makefixdb
	cp lib/libfig.a /usr/local/lib

# --------------------------

clean:
	rm -f makerouter
	rm -f bin/makerouter
	rm -f bin/makefixdb
	rm -f lib/libfig.a
	rm -f res/spinna.min.js
	rm -f res/spinna.js
	rm -f res/spinna.scss
	pushd progs/fig; make clean


res/spinna.min.js: $(JSFILES)
	js -C $(addprefix -f ,$(JSFILES))
	$(YUI) $(JSFILES) -o res/spinna.min.js

res/spinna.js: $(JSFILES)
	js -C $(addprefix -f ,$(JSFILES))
	cat $(JSFILES) > res/spinna.js

res/spinna.scss: $(SCSSFILES)
	cat $(SCSSFILES) > res/spinna.scss

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
	cp bin/makefixdb $(DESTDIR)/usr/bin
	strip $(DESTDIR)/usr/bin/makefixdb
	cp -R src/backtrace $(DESTDIR)/usr/include/spinna/src
	cp -R src/jaypha $(DESTDIR)/usr/include/spinna/src
	cp src/*.d $(DESTDIR)/usr/include/spinna/src
	cp -R thirdparty $(DESTDIR)/usr/include/spinna
	cp -R licenses $(DESTDIR)/usr/include/spinna
	cp -R res $(DESTDIR)/usr/include/spinna
	cp lib/libfig.a $(DESTDIR)/usr/lib64

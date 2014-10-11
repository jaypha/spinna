RDMD = rdmd

SPINNA_ROOT = .

DYAML_PROJ = /home/jason/projects/dyaml_0.4/source
include makefile.include

BININSTALL = /usr/local/bin
LIBINSTALL = /usr/local/lib

LIBDIR = /usr/lib64/mysql .
LIBS = fcgi dyaml mysqlclient
IMPDIR =  $(SPINNA_ROOT)/src $(DYAML_PROJ)

LIBFLAGS= $(addprefix -L-l,$(LIBS)) $(addprefix -L-L,$(LIBDIR))

JFLAGS = $(addprefix -J,$(IMPDIR))
IFLAGS = $(addprefix -I,$(IMPDIR))

DFLAGS = $(IFLAGS) $(JFLAGS)

RDFLAGS = $(DFLAGS) -release -O
DDFLAGS = $(DFLAGS) -g -debug

LFLAGS = $(LIBFLAGS)

build: bin lib js css

css: res/_spinna.scss res/_spinna_no_widgets.scss

js: res/spinna.js res/spinna_no_widgets.js

bin: bin/makerouter

# --------------------------

bin/makerouter: src/makerouter.d
	$(RDMD) $(RDFLAGS) $(LFLAGS) -ofbin/makerouter --build-only src/makerouter.d

# makerouter for testing

makerouter: src/makerouter.d
	$(RDMD) $(DDFLAGS) $(LFLAGS) -ofmakerouter --build-only src/makerouter.d

# --------------------------

# --------------------------
# This is for installing support programs, not finished software.

install:
	cp bin/makerouter $(BININSTALL)
	strip $(BININSTALL)/makerouter

# --------------------------

clean:
	rm -f makerouter
	rm -f bin/*
	rm -f lib/*
	rm -f res/*

res/spinna.js: $(JSFILES) $(JSWFILES)
	js -C $(addprefix -f ,$(JSFILES)) $(addprefix -f ,$(JSWFILES))
	cat $(JSFILES) $(JSWFILES) > res/spinna.js

res/spinna_no_widgets.js: $(JSFILES)
	js -C $(addprefix -f ,$(JSFILES))
	cat $(JSFILES) > res/spinna_no_widgets.js

res/_spinna.scss: $(SCSSFILES) $(SCSSWFILES)
	cat $(SCSSFILES) $(SCSSWFILES) > res/_spinna.scss

res/_spinna_no_widgets.scss: $(SCSSFILES)
	#cat $(SCSSFILES) > res/_spinna_no_widgets.scss
	touch res/_spinna_no_widgets.scss

test:
	$(RDMD) $(DDFLAGS) $(LFLAGS) -J./src_test -unittest src_test/test_main.d

#----------------------------------------------------
# debug builds

http_request:
	$(RDMD) $(DDFLAGS) $(LFLAGS) --build-only -debug=http_request -unittest -ofrequest src/jaypha/spinna/request.d

#----------------------------------------------------
# Install for rpm

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

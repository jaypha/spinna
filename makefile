# Makefile for compiling makerouter, collecting javascript and scss files,
# and for creating RPM modules
# Designed for Fedora. Should be compatible with RPM systems
#
# Copyright 2014-15 Jaypha.
# Distributed under the Boost V1.0 license.

RDMD = rdmd

SPINNA_ROOT = .
DUB_ROOT = $(HOME)/.dub/packages
BININSTALL = /usr/local/bin
LIBINSTALL = /usr/local/lib

include makefile.include


DUB_DIRS = $(addprefix $(DUB_ROOT)/,$(DUB_PACKAGES))

LIBDIR = $(DUB_ROOT)/dyaml-0.5.0 .
LIBS = fcgi dyaml


IMPDIR =  $(SPINNA_ROOT)/src $(DUB_DIRS)

LIBFLAGS= $(addprefix -L-l,$(LIBS)) $(addprefix -L-L,$(LIBDIR))

JFLAGS = $(addprefix -J,$(IMPDIR))
IFLAGS = $(addprefix -I,$(IMPDIR))

DFLAGS = $(IFLAGS) $(JFLAGS)

RDFLAGS = $(DFLAGS) -release -O
DDFLAGS = $(DFLAGS) -g -debug

LFLAGS = $(LIBFLAGS)

TESTSRC = $(addprefix $(SPINNA_ROOT)/srctest/,$(TESTFILES))

build: bin res

res: css js

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

#----------------------------------------------------
# Javascript and css resources

res/spinna.js: $(JSFILES) $(JSWFILES)
	js -C $(addprefix -f ,$(JSFILES)) $(addprefix -f ,$(JSWFILES))
	cat $(JSFILES) $(JSWFILES) > res/spinna.js

res/spinna_no_widgets.js: $(JSFILES)
	js -C $(addprefix -f ,$(JSFILES))
	cat $(JSFILES) > res/spinnanowidgets.js

res/_spinna.scss: $(SCSSFILES) $(SCSSWFILES)
	cat $(SCSSFILES) $(SCSSWFILES) > res/_spinna.scss

res/_spinna_no_widgets.scss: $(SCSSFILES)
	#cat $(SCSSFILES) > res/_spinnanowidgets.scss
	touch res/_spinnanowidgets.scss

#----------------------------------------------------
# Test programs for code that cannot be tested with unittest.

test:
	for i in $(TESTFILES); do \
		echo $$i; \
	$(RDMD) -I./srctest $(DDFLAGS) $(LFLAGS) -of./bin/$$i -J./srctest -unittest ./srctest/$$i.d ; \
	done
	echo finished testing


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

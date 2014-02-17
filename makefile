RDMD = rdmd

YUI = java -jar progs/yuicompressor-2.4.8.jar

SPINNA_ROOT = .
IMPDIR = 

include makefile.include

DFLAGS = $(IFLAGS) $(JFLAGS)

RDFLAGS = $(DFLAGS) -release -O
DDFLAGS = $(DFLAGS) -g -debug

LFLAGS = $(LIBFLAGS)

build: bin lib js css

css: res/spinna.scss

js: res/spinna.js

deps:
	$(RDMD) $(RDFLAGS) --makedepend progs/makerouter.d > deps.include
	echo "	touch progs/makerouter.d" >> deps.include
	$(RDMD) $(RDFLAGS) --makedepend progs/dbmake.d >> deps.include
	echo "	touch progs/dbmake.d" >> deps.include

bin: bin/makerouter bin/dbmake

bin/makerouter: progs/makerouter.d lib/libfig.a
	$(RDMD) $(RDFLAGS) $(LFLAGS) -ofbin/makerouter --build-only progs/makerouter.d

bin/dbmake: progs/dbmake.d lib/libfig.a
	$(RDMD) $(RDFLAGS) $(LFLAGS) -ofbin/dbmake --build-only progs/dbmake.d

lib: lib/libfig.a

lib/libfig.a:
	pushd progs/fig; make lib
	cp progs/fig/libfig.a lib

install:
	cp bin/makerouter /usr/local/bin
	strip /usr/local/bin/makerouter
	cp bin/dbmake /usr/local/bin
	strip /usr/local/bin/dbmake
	cp lib/libfig.a /usr/local/lib

clean:
	rm -f bin/makerouter
	rm -f bin/dbmake
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

include deps.include

test:
	$(RDMD) $(DDFLAGS) $(LFLAGS) -J./src_test -unittest src_test/test_main.d

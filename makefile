RDMD = rdmd

YUI = java -jar progs/yuicompressor-2.4.8.jar

SPINNA_ROOT = .
IMPDIR = 

include makefile.include

DFLAGS = $(IFLAGS) $(JFLAGS)

LFLAGS = $(LIBFLAGS)

build: bin lib res/spinna.js res/spinna.scss

deps:
	$(RDMD) $(DFLAGS) --makedepend progs/makerouter.d > deps.include
	$(RDMD) $(DFLAGS) --makedepend progs/dbmake.d >> deps.include

bin: bin/makerouter bin/dbmake

bin/makerouter: progs/makerouter.d lib/libfig.a
	$(RDMD) $(DFLAGS) $(LFLAGS) -ofbin/makerouter --build-only progs/makerouter.d

bin/dbmake: progs/dbmake.d lib/libfig.a
	$(RDMD) $(DFLAGS) $(LFLAGS) -ofbin/dbmake --build-only progs/dbmake.d

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
	rm bin/makerouter
	rm bin/dbmake
	rm lib/libfig.a
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
	$(RDMD) $(DFLAGS) $(LFLAGS) -J./src_test -unittest src_test/test_main.d

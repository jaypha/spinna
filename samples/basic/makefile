# This project defines a simple service to demonstrate how to use the framework.

DC = rdmd

DUB_ROOT = $(HOME)/.dub/packages

DUB_PACKAGES = backtrace-d-master/source \
               fcgi-loop-1.2.0/src \
               jaypha-base-1.0.0/src \
               jaypha-inet-0.9.1/src \


SPINNA_ROOT = ../..

SRCDIR = src

ROUTER_DEF_DIR = router

LIBS = fcgi
IMPDIR = $(SRCDIR) $(SPINNA_ROOT)/src $(addprefix $(DUB_ROOT)/,$(DUB_PACKAGES))

LIBFLAGS= $(addprefix -L-l,$(LIBS)) $(addprefix -L-L,$(LIBDIR))

JFLAGS = $(addprefix -J,$(IMPDIR))
IFLAGS = $(addprefix -I,$(IMPDIR))

DFLAGS = $(IFLAGS) $(JFLAGS)
RDFLAGS = $(DFLAGS) -release -O
DDFLAGS = $(DFLAGS) -g -debug

LFLAGS = $(LIBFLAGS)

dev: bin

# Binaries

bin: router bin/console bin/simple.fcgi

console: bin/console

bin/console: src/console.d src/gen/router.d
	$(DC) $(DDFLAGS) $(LFLAGS) -version=console -ofbin/console --build-only src/console.d

fcgi: bin/simple.fcgi

bin/simple.fcgi: src/fcgi.d src/gen/router.d
	$(DC) $(DDFLAGS) $(LFLAGS) -ofbin/simple.fcgi --build-only src/fcgi.d

test: src/test.d
	$(DC) $(DDFLAGS) $(LFLAGS) --build-only src/test.d

# Router code generation

router: src/gen/router.d

src/gen/router.d: $(ROUTER_DEF_DIR)/_.yaml
	makerouter < $(ROUTER_DEF_DIR)/_.yaml > src/gen/router.d

# Admin

clean:
	rm -f bin/console
	rm -f bin/simple.fcgi
	rm -f src/gen/*.d

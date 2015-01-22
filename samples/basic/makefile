DC = rdmd

DUB_DIR = ~/.dub/packages

DUB_PACKAGES = backtrace-d-master/source \
               fcgi-loop-1.2.0/src \

SPINNA_ROOT = ../..

SRCDIR = src

ROUTER_DEF_DIR = router

LIBS = fcgi
IMPDIR = $(SRCDIR) $(SPINNA_ROOT)/src $(addprefix $(DUB_DIR)/,$(DUB_PACKAGES))

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

# Router code generation

router: src/gen/router.d

src/gen/router.d: $(ROUTER_DEF_DIR)/_.yaml
	makerouter -dsrc < $(ROUTER_DEF_DIR)/_.yaml

# Admin

clean:
	rm -f bin/console
	rm -f bin/simple.fcgi
	rm -f src/gen/*.d
	rm -f src/gen/*.tpl

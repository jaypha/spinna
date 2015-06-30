# This project defines a simple service to demonstrate how to use the framework.

DC = rdmd

DUB_ROOT = $(HOME)/.dub/packages

DUB_PACKAGES = jaypha-base-1.0.1/src \
               jaypha-inet-0.9.5/src \
               openssl-master \
               libevent-master \
               memutils-0.3.5/source \
               vibe-d-0.7.23/source\

SPINNA_ROOT = ../..

LIBDIR = $(DUB_ROOT)/vibe-d-0.7.23

SRCDIR = src

ROUTER_DEF_DIR = router

DVERSION = VibeLibeventDriver VibeDefaultMain
DVERSIONFLAGS = $(addprefix -version=,$(DVERSION))

LIBS = event ssl crypto vibe-d
IMPDIR = $(SRCDIR) $(SPINNA_ROOT)/src $(addprefix $(DUB_ROOT)/,$(DUB_PACKAGES))

LIBFLAGS= $(addprefix -L-l,$(LIBS)) $(addprefix -L-L,$(LIBDIR))

JFLAGS = $(addprefix -J,$(IMPDIR))
IFLAGS = $(addprefix -I,$(IMPDIR))

DFLAGS = $(IFLAGS) $(JFLAGS) $(DVERSIONFLAGS)
RDFLAGS = $(DFLAGS) -release -O
DDFLAGS = $(DFLAGS) -g -debug

LFLAGS = $(LIBFLAGS)

dev: bin

# Binaries

bin: router bin/app

bin/app: src/app.d src/pages.d src/gen/router.d
	$(DC) $(DDFLAGS) $(LFLAGS) -ofbin/app --build-only src/app.d

# Router code generation

router: src/gen/router.d

src/gen/router.d: $(ROUTER_DEF_DIR)/_.yaml
	makerouter < $(ROUTER_DEF_DIR)/_.yaml > src/gen/router.d

# Admin

clean:
	rm -f bin/app
	rm -f src/gen/*.d

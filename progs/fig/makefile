#
# Makefile for creating the fig library, and test program.
#
# Part of the Fig configuration language project.
#
# Copyright Jaypha 2013.
#
# Distributed under the Boost Software License, Version 1.0.
# (See http://www.boost.org/LICENSE_1_0.txt)
#
# Authors: Jason den Dulk
#

install: lib
	cp libfig.a /usr/local/lib

lib: libfig.a

test: libfig.a test-main.c
	gcc test-main.c -o testfig -L. -lfig
	rm -f test-main.o

libfig.a: grammer.c lex.yy.c defs.h figparser.h
	gcc -c -Os -s grammer.c lex.yy.c
	ar rcs libfig.a grammer.o lex.yy.o
	rm -f *.o

grammer.c: grammer.txt
	bison -d -o grammer.c grammer.txt

lex.yy.c: tokens.txt
	flex tokens.txt

clean:
	rm -f testfig
	rm -f libfig.a
	rm -f lex.h
	rm -f lex.yy.c
	rm -f grammer.h
	rm -f grammer.c

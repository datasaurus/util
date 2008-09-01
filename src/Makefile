# $Id: Makefile,v 1.2 2008/08/30 14:28:47 tkgeomap Exp $

CFLAGS = -g -Wall -Wmissing-prototypes
EXECS = geog

geog : geog_app.c  geog_lib.c
	cc ${CFLAGS} -o geog geog_app.c  geog_lib.c -lm

hash.o : hash.c hash.h
	cc ${CFLAGS} -c hash.c

alloc.o : alloc.c alloc.h
	cc ${CFLAGS} -c alloc.c

clean :
	rm -f ${EXECS} *core*  *.o

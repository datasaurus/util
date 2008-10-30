# $Id: Makefile,v 1.4 2008/10/02 21:20:11 gcarrie Exp $

CFLAGS = -g -Wall -Wmissing-prototypes
EXECS = geog

geog : geog_app.c  geog_lib.c
	cc ${CFLAGS} -o geog geog_app.c  geog_lib.c -lm

hash.o : hash.c hash.h
	cc ${CFLAGS} -c hash.c

alloc.o : alloc.c alloc.h
	cc ${CFLAGS} -c alloc.c

allocf.o : allocf.c allocf.h
	cc ${CFLAGS} -c allocf.c

err_msg.o : err_msg.c err_msg.h
	cc ${CFLAGS} -c err_msg.c

clean :
	rm -f ${EXECS} *core*  *.o

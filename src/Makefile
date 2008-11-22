# $Id: Makefile,v 1.7 2008/11/22 18:53:30 gcarrie Exp $

CFLAGS = -g -Wall -Wmissing-prototypes
EXECS = geog allocfvi 

geog : geog_app.c  geog_lib.c
	cc ${CFLAGS} -o geog geog_app.c  geog_lib.c -lm

allocfvi : allocfvi.c alloc2f.c alloc.c err_msg.c
	cc ${CFLAGS} -o allocfvi allocfvi.c alloc2f.c alloc.c err_msg.c

hash.o : hash.c hash.h
	cc ${CFLAGS} -c hash.c

alloc.o : alloc.c alloc.h
	cc ${CFLAGS} -c alloc.c

alloc2f.o : alloc2f.c alloc2f.h
	cc ${CFLAGS} -c alloc2f.c

alloc3f.o : alloc3f.c alloc3f.h
	cc ${CFLAGS} -c alloc3f.c

alloc4f.o : alloc4f.c alloc4f.h
	cc ${CFLAGS} -c alloc4f.c

err_msg.o : err_msg.c err_msg.h
	cc ${CFLAGS} -c err_msg.c

clean :
	rm -f ${EXECS} *core*  *.o *.ps

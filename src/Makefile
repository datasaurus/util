#- Makefile --
#-	This is the make file for everything in the src directory.
#-	It does not intend to create or install complete applications
#-	or libraries, but may help development of such.
#-	
# Copyright (c) 2008 Gordon D. Carrie
# Licensed under the Open Software License version 3.0
#
# Please send feedback to dev0@trekix.net
#
# $Revision: 1.13 $ $Date: 2008/12/17 22:55:56 $

CFLAGS = -g -Wall -Wmissing-prototypes
#LFLAGS = -L/usr/local/lib -lefence
EXECS = geog allocfvi 

geog : geog_app.c  geog_lib.c
	cc ${CFLAGS} -o geog geog_app.c  geog_lib.c -lm

SRC = allocfvi.c alloc4f.c alloc3f.c alloc2f.c alloc.c err_msg.c
allocfvi : ${SRC}
	cc ${CFLAGS} -o allocfvi ${SRC} ${LFLAGS}

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
	rm -f ${EXECS} *core*  *.o *.ps *.out

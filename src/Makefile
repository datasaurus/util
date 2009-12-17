#- Makefile --
#-	This is the make file for everything in the src directory.
#-	It does not intend to create or install complete applications
#-	or libraries, but may help development of such.
#-	
# Copyright (c) 2008 Gordon D. Carrie
# All rights reserved
#
# Please send feedback to dev0@trekix.net
#
# $Revision: 1.21 $ $Date: 2009/09/25 21:33:13 $

CFLAGS = -g -Wall -Wmissing-prototypes
#LFLAGS = -L/usr/local/lib -lefence
EXECS = allocfvi bhead
OBJ = alloc.o alloc2f.o alloc3f.o alloc4f.o allocfvi.o err_msg.o hash.o mstring.o

obj : ${OBJ}

bhead : bhead.c
	cc ${CFLAGS} -o bhead bhead.c

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

mstring.o : mstring.c mstring.h
	cc ${CFLAGS} -c mstring.c

clean :
	rm -f ${EXECS} *core*  *.o *.ps *.out

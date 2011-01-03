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
# $Revision: 1.25 $ $Date: 2009/12/22 21:46:37 $

CC = cc
CFLAGS = -g -Wall -Wmissing-prototypes
#LFLAGS = -L/usr/local/lib -lefence
EXECS = allocfvi bhead prhash
OBJ = alloc.o alloc2f.o alloc3f.o alloc4f.o allocfvi.o err_msg.o hash.o str.o

obj : ${OBJ}

bhead : bhead.c
	${CC} ${CFLAGS} -o bhead bhead.c

SRC = allocfvi.c alloc4f.c alloc3f.c alloc2f.c alloc.c err_msg.c
allocfvi : ${SRC}
	${CC} ${CFLAGS} -o allocfvi ${SRC} ${LFLAGS}

SRC = prhash.c hash.c alloc.c err_msg.c
prhash : ${SRC}
	${CC} ${CFLAGS} -o prhash ${SRC} ${LFLAGS}

hash.o : hash.c hash.h
	${CC} ${CFLAGS} -c hash.c

alloc.o : alloc.c alloc.h
	${CC} ${CFLAGS} -c alloc.c

alloc2f.o : alloc2f.c alloc2f.h
	${CC} ${CFLAGS} -c alloc2f.c

alloc3f.o : alloc3f.c alloc3f.h
	${CC} ${CFLAGS} -c alloc3f.c

alloc4f.o : alloc4f.c alloc4f.h
	${CC} ${CFLAGS} -c alloc4f.c

dyn_alloc.o : dyn_alloc.c dyn_alloc.h
	${CC} ${CFLAGS} -c dyn_alloc.c

err_msg.o : err_msg.c err_msg.h
	${CC} ${CFLAGS} -c err_msg.c

str.o : str.c str.h
	${CC} ${CFLAGS} -c str.c

clean :
	rm -f ${EXECS} *core*  *.o *.ps *.out

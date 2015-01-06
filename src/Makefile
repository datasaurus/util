#- Makefile --
#-	This is the make file for everything in the src directory.
#-	It does not intend to create or install complete applications
#-	or libraries, but may help development of such.
#-	
# Copyright (c) 2011, Gordon D. Carrie. All rights reserved.
# 
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# 
#     * Redistributions of source code must retain the above copyright
#     notice, this list of conditions and the following disclaimer.
#     * Redistributions in binary form must reproduce the above copyright
#     notice, this list of conditions and the following disclaimer in the
#     documentation and/or other materials provided with the distribution.
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
# A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
# HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
# SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
# TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
# PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
# LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
# NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
# Please send feedback to dev0@trekix.net
#
# $Revision: 1.30 $ $Date: 2013/01/10 21:21:34 $

CC = cc
CFLAGS = -std=c99 -g -Wall -Wmissing-prototypes
#LFLAGS = -L/usr/local/lib -lefence
EXECS = allocfvi bhead prhash tmexec arr32
OBJ = alloc.o alloc2f.o alloc3f.o alloc4f.o allocfvi.o err_msg.o hash.o str.o

obj : ${OBJ}

tmexec : tmexec.c
	${CC} ${CFLAGS} -o tmexec tmexec.c

bhead : bhead.c
	${CC} ${CFLAGS} -o bhead bhead.c

SRC = allocfvi.c alloc4f.c alloc3f.c alloc2f.c alloc.c err_msg.c
allocfvi : ${SRC}
	${CC} ${CFLAGS} -o allocfvi ${SRC} ${LFLAGS}

SRC = prhash.c hash.c alloc.c err_msg.c
prhash : ${SRC}
	${CC} ${CFLAGS} -o prhash ${SRC} ${LFLAGS}

arr32 : arr32.c
	${CC} ${CFLAGS} -o arr32 arr32.c

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
	rm -fr ${EXECS} *core*  *.o *.ps *.out *.dSYM

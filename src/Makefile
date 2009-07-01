#- Makefile --
#-	This is the make file for everything in the src directory.
#-	It does not intend to create or install complete applications
#-	or libraries, but may help development of such.
#-	
# Copyright (c) 2008 Gordon D. Carrie
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#
# Please send feedback to dev0@trekix.net
#
# $Revision: 1.16 $ $Date: 2008/12/19 21:27:58 $

CFLAGS = -g -Wall -Wmissing-prototypes
#LFLAGS = -L/usr/local/lib -lefence
EXECS = allocfvi 
OBJ = alloc.o alloc2f.o alloc3f.o alloc4f.o allocfvi.o err_msg.o hash.o

obj : ${OBJ}

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

# $Id$

EXECS = geog

geog : geog_app.c  geog_lib.c
	cc -o geog geog_app.c  geog_lib.c -lm

clean :
	rm -f ${EXECS} *core*  *.o

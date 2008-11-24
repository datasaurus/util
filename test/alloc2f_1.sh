#!/bin/sh
#
#- alloc2f_1.sh --
#-	This script tests the allocators defined in src/alloc2f.c
#-	It allocates, accesses, and then frees a two dimensional array.
#-
# Copyright (c) 2008 Gordon D. Carrie
# Licensed under the Open Software License version 3.0
#
# Please send feedback to user0@tkgeomap.org
#
# $Id: alloc2f_1.sh,v 1.3 2008/11/24 04:15:43 gcarrie Exp $
#
########################################################################

# This is the remove command.  Change this to : to retain intermediate results.
RM='rm -f'
#RM=:

# Array in the test application will have dimensions JMAX by IMAX.
# Set these to something substantial but not overwhelming.
JMAX=10000
IMAX=10000

CC="cc"
CFLAGS="-g -Wall -Wmissing-prototypes"

# Here is the source code for the driver application.
cat > alloc2f_1.c << END
#include <stdio.h>
#include <err_msg.h>
#include <alloc2f.h>

int main(void)
{
    long jmax, imax;
    long j, i;
    float *d;
    float **dat = NULL, **d2, **e2;

    jmax = ${JMAX};
    imax = ${IMAX};
    fprintf(stderr, "Creating a %ld by %ld array (%ld bytes)\n",
	    jmax, imax, jmax * imax * sizeof(float));

    dat = calloc2f(jmax, imax);
    if ( !dat ) {
	fprintf(stderr, "Could not allocate dat\n%s\n", err_get());
	return 1;
    }
    for (d2 = dat, e2 = d2 + 1; *e2 ; d2++, e2++) {
	j = d2 - dat;
	for (d = *d2; d < *e2; d++) {
	    i = d - *d2;
	    *d = 10 * j + i;
	}
    }
    printf("dat[1][1] = %8.1f\n", dat[1][1]);
    printf("dat[9][9] = %8.1f\n", dat[9][9]);
    printf("dat[jmax-1][imax-1] = %8.1f\n", dat[jmax-1][imax-1]);
    free2f(dat);
    return 0;
}
END

if ! $CC $CFLAGS -Isrc -o alloc2f_1 alloc2f_1.c src/alloc2f.c src/alloc.c src/err_msg.c
then
    echo "Could not compile the test application"
    exit 1
fi

echo test1: building and running alloc2f_1
echo ""
echo Starting test1
alloc2f_1
echo Done with test1
echo ""

echo test2: building and running allocf1 with memory trace.
echo An account of allocations and calls to free should appear on terminal
echo ""
echo Starting test2
export MEM_DEBUG=2
alloc2f_1
echo Done with test2
echo ""
unset MEM_DEBUG

echo test3: building and running alloc2f_1.
echo Sending memory trace to findleaks, which should not find anything.
export MEM_DEBUG=2
echo ""
echo Starting test3
alloc2f_1 2>&1 | src/findleaks
echo Done with test3
echo ""
unset MEM_DEBUG

echo test4: simulate allocation failure in alloc2f_1
echo This should produce a warning about failure to allocate dat.
export MEM_FAIL="src/alloc2f.c:41"
echo ""
echo Starting test4
alloc2f_1
echo Done with test4
echo ""
unset MEM_FAIL

echo test5: simulate a later allocation failure in alloc2f_1
echo This should produce a warning about failure to allocate dat.
export MEM_FAIL="src/alloc2f.c:46"
echo ""
echo Starting test5
alloc2f_1
echo Done with test5
echo ""
unset MEM_FAIL

echo test6: simulate later allocation failure in alloc2f_1 with memory tracing
echo This should produce a warning about failure to allocate dat.
echo Trace output should show no leaks
export MEM_FAIL="src/alloc2f.c:46"
export MEM_DEBUG=3
echo ""
echo Starting test6
alloc2f_1 3>&1
echo Done with test6
echo ""
unset MEM_FAIL

$RM alloc2f_1.c alloc2f_1

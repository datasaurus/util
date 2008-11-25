#!/bin/sh
#
#- alloc3f_1.sh --
#-	This script tests the allocators defined in src/alloc3f.c
#-	It allocates, accesses, and then frees a two dimensional array.
#-
# Copyright (c) 2008 Gordon D. Carrie
# Licensed under the Open Software License version 3.0
#
# Please send feedback to user0@tkgeomap.org
#
# $Id: alloc3f_1.sh,v 1.2 2008/11/24 06:10:55 gcarrie Exp $
#
########################################################################

# This is the remove command.  Change this to : to retain intermediate results.
RM='rm -f'
#RM=:

# Array in the test application will have dimensions KMAX by JMAX by IMAX.
# Set these to something substantial but not overwhelming.
KMAX=${KMAX:-"400"}
JMAX=${JMAX:-"400"}
IMAX=${IMAX:-"400"}

CC="cc"
CFLAGS="-g -Wall -Wmissing-prototypes"

# Here is the source code for the driver application.
cat > alloc3f_1.c << END
#include <stdio.h>
#include <err_msg.h>
#include <alloc3f.h>

int main(void)
{
    long kmax, jmax, imax;
    long k, j, i;
    float *d;
    float **d2, **e2;
    float ***dat = NULL, ***d3, ***e3;

    kmax = $KMAX;
    jmax = $JMAX;
    imax = $IMAX;
    fprintf(stderr, "Creating a %ld by %ld by %ld array (%ld bytes)\n",
	    kmax, jmax, imax, kmax * jmax * imax * sizeof(float));

    dat = calloc3f(kmax, jmax, imax);
    if ( !dat ) {
	fprintf(stderr, "Could not allocate dat\n%s\n", err_get());
	return 1;
    }
    for (d3 = dat, e3 = d3 + 1; *e3; d3++, e3++) {
	k = d3 - dat;
	for (d2 = *d3, e2 = d2 + 1; d2 < *e3; d2++, e2++) {
	    j = d2 - *d3;
	    for (d = *d2; d < *e2; d++) {
		i = d - *d2;
		*d = 100 * k + 10 * j + i;
	    }
	}
    }
    printf("dat[1][1][1] = %8.1f\n", dat[1][1][1]);
    printf("dat[9][9][9] = %8.1f\n", dat[9][9][9]);
    printf("dat[kmax-1][jmax-1][imax-1] = %8.1f\n", dat[kmax-1][jmax-1][imax-1]);
    free3f(dat);
    return 0;
}
END

if ! cc -Isrc -o alloc3f_1 alloc3f_1.c src/alloc3f.c src/alloc.c src/err_msg.c
then
    echo "Could not compile the test application"
    exit 1
fi

echo test1: building and running alloc3f_1
echo ""
echo Starting test1
alloc3f_1
echo Done with test1
echo ""

echo test2: building and running allocf1 with memory trace.
echo An account of allocations and calls to free should appear on terminal
echo ""
echo Starting test2
export MEM_DEBUG=2
alloc3f_1
echo Done with test2
echo ""
unset MEM_DEBUG

echo test3: building and running alloc3f_1.
echo Sending memory trace to findleaks, which should not find anything.
export MEM_DEBUG=2
echo ""
echo Starting test3
alloc3f_1 2>&1 | src/findleaks
echo Done with test3
echo ""
unset MEM_DEBUG

echo test4: simulate allocation failure in alloc3f_1
echo This should produce a warning about failure to allocate dat.
export MEM_FAIL="src/alloc3f.c:41"
echo ""
echo Starting test4
alloc3f_1
echo Done with test4
echo ""
unset MEM_FAIL

echo test5: simulate a later allocation failure in alloc3f_1
echo This should produce a warning about failure to allocate dat.
export MEM_FAIL="src/alloc3f.c:46"
echo ""
echo Starting test5
alloc3f_1
echo Done with test5
echo ""
unset MEM_FAIL

echo test6: simulate later allocation failure in alloc3f_1 with memory tracing
echo This should produce a warning about failure to allocate dat.
echo Trace output should show no leaks
export MEM_FAIL="src/alloc3f.c:46"
export MEM_DEBUG=3
echo ""
echo Starting test6
alloc3f_1 3>&1
echo Done with test6
echo ""
unset MEM_FAIL

$RM alloc3f_1.c alloc3f_1

#!/bin/sh
#
#- alloc3f_1.sh --
#-	This script tests the allocators defined in src/alloc3f.c
#-	It allocates, accesses, and then frees a two dimensional array.
#-
# Copyright (c) 2008 Gordon D. Carrie
# Licensed under the Open Software License version 3.0
#
# Please send feedback to dev0@trekix.net
#
# $Id: alloc3f_1.sh,v 1.9 2008/12/05 18:17:44 gcarrie Exp $
#
########################################################################

# Set RM to : to save intermediate files
RM=${RM:-'rm -f'}

# Array in the test application will have dimensions KMAX by JMAX by IMAX.
# Set these to something substantial but not overwhelming.
KMAX=${KMAX:-"379"}
JMAX=${JMAX:-"383"}
IMAX=${IMAX:-"421"}

CC="cc"
CFLAGS="-g -Wall -Wmissing-prototypes"

# Here is the source code for the driver application.
cat > alloc3f_1.c << END
#include <stdio.h>
#include <err_msg.h>
#include <alloc3f.h>

int main(int argc, char *argv[])
{
    long kmax, jmax, imax;
    long k, j, i;
    float ***dat = NULL, ***p3, **p2, *p;

    kmax = 379;
    jmax = 383;
    imax = 421;
    fprintf(stderr, "Creating a %ld by %ld by %ld array (%.1f MB)\n",
	    kmax, jmax, imax, (kmax * jmax * imax * sizeof(float)) / 1048576.0);

    /* Create array and access with conventional indexing */
    dat = calloc3f(kmax, jmax, imax);
    if ( !dat ) {
	fprintf(stderr, "Could not allocate dat\n%s\n", err_get());
	return 1;
    }
    for (k = 0; k < kmax; k++) {
	for (j = 0; j < jmax; j++) {
	    for (i = 0; i < imax; i++) {
		dat[k][j][i] = 100 * k + 10 * j + i;
	    }
	}
    }
    if (kmax > 1 && jmax > 1 && imax > 1) {
	printf("dat[1][1][1] = %8.1f\n", dat[1][1][1]);
    }
    if (kmax > 9 && jmax > 9 && imax > 9) {
	printf("dat[9][9][9] = %8.1f\n", dat[9][9][9]);
    }
    printf("dat[kmax-1][jmax-1][imax-1] = %8.1f\n", dat[kmax-1][jmax-1][imax-1]);
    free3f(dat);
    
    /* Create array and access with pointers */
    dat = calloc3f(kmax, jmax, imax);
    if ( !dat ) {
        fprintf(stderr, "%s: Could not allocate dat.\n%s", argv[0], err_get());
        return 1;
    }
    for (p3 = dat; p3[1]; p3++) {
	k = p3 - dat;
	for (p2 = p3[0]; p2 < p3[1]; p2++) {
	    j = p2 - *p3;
	    for (p = p2[0]; p < p2[1]; p++) {
		i = p - *p2;
		*p = 100 * k + 10 * j + i;
	    }
	}
    }
    if (kmax > 1 && jmax > 1 && imax > 1) {
	printf("dat[1][1][1] = %8.1f\n", dat[1][1][1]);
    }
    if (kmax > 9 && jmax > 9 && imax > 9) {
	printf("dat[9][9][9] = %8.1f\n", dat[9][9][9]);
    }
    printf("dat[kmax-1][jmax-1][imax-1] = %8.1f\n", dat[kmax-1][jmax-1][imax-1]);
    free3f(dat);
    return 0;
}
END

# Standard output from the test program should match contents of file correct.
cat > correct << END
dat[1][1][1] =    111.0
dat[9][9][9] =    999.0
dat[kmax-1][jmax-1][imax-1] =  42040.0
dat[1][1][1] =    111.0
dat[9][9][9] =    999.0
dat[kmax-1][jmax-1][imax-1] =  42040.0
END

SRC="alloc3f_1.c src/alloc3f.c src/alloc.c src/err_msg.c"
if ! $CC $CFLAGS -Isrc -o alloc3f_1 $SRC
then
    echo "Could not compile the test application"
    exit 1
fi

echo test1: building and running alloc3f_1
echo ""
echo Starting test1
alloc3f_1 > attempt
if diff correct attempt
then
    echo "test program produced correct output"
else
    echo "test program failed!"
fi
echo Done with test1
echo ""
$RM attempt

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
(alloc3f_1 > attempt) 2>&1 | src/findleaks
if diff correct attempt
then
    echo "test program produced correct output"
else
    echo "test program failed!"
fi
echo Done with test3
echo ""
$RM attempt
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

$RM alloc3f_1.c alloc3f_1 correct

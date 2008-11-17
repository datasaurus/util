#!/bin/sh
#
# This script tests the allocators defined in src/allocf.c
#
# Copyright (c) 2008 Gordon D. Carrie
#
# Licensed under the Open Software License version 3.0
#
# Please send feedback to user0@tkgeomap.org
#
# $Id: allocf1.sh,v 1.5 2008/11/16 04:46:20 gcarrie Exp $
#
########################################################################

# This is the remove command.  Change this to : to retain intermediate results.

RM='rm -f'
#RM=:

# Here is the source code for the driver application.
# It allocates, accesses, and then frees a some arrays.

cat > allocf1.c << END
#include <stdio.h>
#include <allocf.h>

int main(void)
{
    long lmax, kmax, jmax, imax;
    long l, k, j, i;
    float **x2 = NULL;
    float ***x3 = NULL;
    float ****x4 = NULL;

    lmax = 10;
    kmax = 100;
    jmax = 100;
    imax = 100;

    x2 = mallocf2(jmax, imax);
    if ( !x2 ) {
	fprintf(stderr, "Could not allocate x2\n");
	return 1;
    }
    for (j = 0; j < jmax; j++) {
	for (i = 0; i < imax; i++) {
	    x2[j][i] = 100 * j + 10 * i;
	}
    }
    printf("x2[1][1] = %f\n", x2[1][1]);
    printf("x2[9][9] = %f\n", x2[9][9]);
    printf("x2[jmax-1][imax-1] = %f\n", x2[jmax-1][imax-1]);
    freef2(x2);

    x3 = mallocf3(kmax, jmax, imax);
    if ( !x3 ) {
	fprintf(stderr, "Could not allocate x3\n");
	return 1;
    }
    for (k = 0; k < kmax; k++) {
	for (j = 0; j < jmax; j++) {
	    for (i = 0; i < imax; i++) {
		x3[k][j][i] = 100 * k + 10 * j + i;
	    }
	}
    }
    printf("x3[1][1][1] = %f\n", x3[1][1][1]);
    printf("x3[9][9][9] = %f\n", x3[9][9][9]);
    printf("x3[kmax-1][jmax-1][imax-1] = %f\n", x3[kmax-1][jmax-1][imax-1]);
    freef3(x3);

    x4 = mallocf4(lmax, kmax, jmax, imax);
    if ( !x4 ) {
	fprintf(stderr, "Could not allocate x4\n");
	return 1;
    }
    for (l = 0; l < lmax; l++) {
	for (k = 0; k < kmax; k++) {
	    for (j = 0; j < jmax; j++) {
		for (i = 0; i < imax; i++) {
		    x4[l][k][j][i] = 1000 * l + 100 * k + 10 * j + i;
		}
	    }
	}
    }
    printf("x4[1][1][1][1] = %f\n", x4[1][1][1][1]);
    printf("x4[9][9][9][9] = %f\n", x4[9][9][9][9]);
    printf("x4[lmax-1][kmax-1][jmax-1][imax-1] = %f\n",
	    x4[lmax-1][kmax-1][jmax-1][imax-1]);
    freef4(x4);

    return 0;
}
END

echo test1: building and running allocf1
cc -Isrc -o allocf1 allocf1.c src/allocf.c src/alloc.c src/err_msg.c
echo ""
echo Starting test1
allocf1
echo Done with test1
echo ""
$RM allocf1

echo test2: building and running allocf1 with memory trace.
echo An account of allocations and calls to free should appear on terminal
cc -Isrc -o allocf1 allocf1.c src/allocf.c src/alloc.c src/err_msg.c
echo ""
echo Starting test2
export MEM_DEBUG=2
allocf1
echo Done with test2
echo ""
$RM allocf1
unset MEM_DEBUG

echo test3: building and running allocf1.
echo Sending memory trace to findleaks, which should not find anything.
export MEM_DEBUG=2
cc -Isrc -o allocf1 allocf1.c src/allocf.c src/alloc.c src/err_msg.c
echo ""
echo Starting test3
allocf1 2>&1 | src/findleaks
echo Done with test3
echo ""
$RM allocf1
unset MEM_DEBUG

echo test4: simulate allocation failure in allocf1
echo This should produce a warning about failure to allocate x2.
cc -Isrc -o allocf1 allocf1.c src/allocf.c src/alloc.c src/err_msg.c
export MEM_FAIL="src/allocf.c:41"
echo ""
echo Starting test4
allocf1
echo Done with test4
echo ""
$RM allocf1
unset MEM_FAIL

echo test5: simulate a later allocation failure in allocf1
echo This should produce a warning about failure to allocate x2.
cc -Isrc -o allocf1 allocf1.c src/allocf.c src/alloc.c src/err_msg.c
export MEM_FAIL="src/allocf.c:46"
echo ""
echo Starting test5
allocf1
echo Done with test5
echo ""
$RM allocf1
unset MEM_FAIL

echo test6: simulate later allocation failure in allocf1 with memory tracing
echo This should produce a warning about failure to allocate x2.
echo Trace output should show no leaks
cc -Isrc -o allocf1 allocf1.c src/allocf.c src/alloc.c src/err_msg.c
export MEM_FAIL="src/allocf.c:46"
export MEM_DEBUG=3
echo ""
echo Starting test6
allocf1 3>&1
echo Done with test6
echo ""
$RM allocf1
unset MEM_FAIL

$RM allocf1.c

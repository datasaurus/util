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
# $Id: $
#
########################################################################

# This is the remove command.  Change this to : to retain intermediate results.

RM='rm -f'

# Here is the source code for the driver application.
# It allocates, accesses, and then frees a 2 dimensional array.

cat > allocf1.c << END
#include <stdio.h>                                                       /* 1 */
#include <allocf.h>                                                      /* 2 */
                                                                         /* 3 */
int main(void)                                                           /* 4 */
{                                                                        /* 5 */
    size_t j_max, i_max;                                                 /* 6 */
    int j, i;                                                            /* 7 */
    float **x;                                                           /* 8 */
                                                                         /* 9 */
    j_max = 1000;                                                        /* 10 */
    i_max = 1000;                                                        /* 11 */
    x = mallocf2(j_max, i_max);                                          /* 12 */
    if ( !x ) {                                                          /* 13 */
	fprintf(stderr, "Could not allocate x\n");                       /* 14 */
	return 1;                                                        /* 15 */
    }                                                                    /* 16 */
    for (j = 0; j < j_max; j++) {                                        /* 17 */
	for (i = 0; i < i_max; i++) {                                    /* 18 */
	    x[j][i] = 100 * j + 10 * i;                                  /* 19 */
	}                                                                /* 20 */
    }                                                                    /* 21 */
    printf("x[1][1] = %f\n", x[1][1]);                                   /* 22 */
    printf("x[9][9] = %f\n", x[9][9]);                                   /* 23 */
    printf("x[999][999] = %f\n", x[999][999]);                           /* 24 */
    freef2(x);                                                           /* 25 */
    return 0;                                                            /* 26 */
}                                                                        /* 27 */
END

echo test1: building and running allocf1
cc -Isrc -o allocf1 allocf1.c src/allocf.c src/alloc.c
echo Starting test1
allocf1
echo Done with test1
echo ""
$RM allocf1

echo test2: building and running allocf1 with memory trace.
echo An account of allocations and calls to free should appear on terminal
cc -Isrc -o allocf1 allocf1.c src/allocf.c src/alloc.c
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
cc -Isrc -o allocf1 allocf1.c src/allocf.c src/alloc.c
echo Starting test3
allocf1 2>&1 | src/findleaks
echo Done with test3
echo ""
$RM allocf1
unset MEM_DEBUG

echo test4: simulate allocation failure in allocf1
echo This should produce a warning about failure to allocate x.
cc -Isrc -o allocf1 allocf1.c src/allocf.c src/alloc.c
export MEM_FAIL="src/allocf.c:33"
echo Starting test4
allocf1
echo Done with test4
echo ""
$RM allocf1
unset MEM_FAIL

echo test5: simulate a later allocation failure in allocf1
echo This should produce a warning about failure to allocate x.
cc -Isrc -o allocf1 allocf1.c src/allocf.c src/alloc.c
export MEM_FAIL="src/allocf.c:37"
echo Starting test5
allocf1
echo Done with test5
echo ""
$RM allocf1
unset MEM_FAIL

echo test6: simulate later allocation failure in allocf1 with memory tracing
echo This should produce a warning about failure to allocate x.
echo Trace output should show now leaks
cc -Isrc -o allocf1 allocf1.c src/allocf.c src/alloc.c
export MEM_FAIL="src/allocf.c:37"
export MEM_DEBUG=3
echo Starting test6
allocf1 3>&1
echo Done with test6
echo ""
$RM allocf1
unset MEM_FAIL

$RM allocf1.c

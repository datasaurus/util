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
# $Id: allocf1.sh,v 1.2 2008/11/15 22:51:06 gcarrie Exp $
#
########################################################################

# This is the remove command.  Change this to : to retain intermediate results.

RM='rm -f'

# Here is the source code for the driver application.
# It allocates, accesses, and then frees a 2 dimensional array.

cat > allocf1.c << END
#include <stdio.h>
#include <allocf.h>

int main(void)
{
    size_t j_max, i_max;
    int j, i;
    float **x = NULL;

    j_max = 1000;
    i_max = 1000;
    x = mallocf2(j_max, i_max);
    if ( !x ) {
	fprintf(stderr, "Could not allocate x\n");
	err_destroy();
	return 1;
    }
    for (j = 0; j < j_max; j++) {
	for (i = 0; i < i_max; i++) {
	    x[j][i] = 100 * j + 10 * i;
	}
    }
    printf("x[1][1] = %f\n", x[1][1]);
    printf("x[9][9] = %f\n", x[9][9]);
    printf("x[999][999] = %f\n", x[999][999]);
    freef2(x);
    err_destroy();
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
echo This should produce a warning about failure to allocate x.
cc -Isrc -o allocf1 allocf1.c src/allocf.c src/alloc.c src/err_msg.c
export MEM_FAIL="src/allocf.c:35"
echo ""
echo Starting test4
allocf1
echo Done with test4
echo ""
$RM allocf1
unset MEM_FAIL

echo test5: simulate a later allocation failure in allocf1
echo This should produce a warning about failure to allocate x.
cc -Isrc -o allocf1 allocf1.c src/allocf.c src/alloc.c src/err_msg.c
export MEM_FAIL="src/allocf.c:40"
echo ""
echo Starting test5
allocf1
echo Done with test5
echo ""
$RM allocf1
unset MEM_FAIL

echo test6: simulate later allocation failure in allocf1 with memory tracing
echo This should produce a warning about failure to allocate x.
echo Trace output should show no leaks
cc -Isrc -o allocf1 allocf1.c src/allocf.c src/alloc.c src/err_msg.c
export MEM_FAIL="src/allocf.c:40"
export MEM_DEBUG=3
echo ""
echo Starting test6
allocf1 3>&1
echo Done with test6
echo ""
$RM allocf1
unset MEM_FAIL

$RM allocf1.c

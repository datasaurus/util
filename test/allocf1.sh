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
# $Id: allocf1.sh,v 1.7 2008/11/19 04:07:16 gcarrie Exp $
#
########################################################################

# This is the remove command.  Change this to : to retain intermediate results.

#RM='rm -f'
RM=:

# Here is the source code for the driver application.
# It allocates, accesses, and then frees a some arrays.

cat > allocf1.c << END
#include <stdio.h>
#include <err_msg.h>
#include <allocf.h>

int main(void)
{
    long jmax, imax;
    long j, i;
    float *p, *q;
    float **dat = NULL, **p2, **q2;

    jmax = 100;
    imax = 100;

    dat = mallocf2(jmax, imax);
    if ( !dat ) {
	fprintf(stderr, "Could not allocate dat\n%s\n", err_get());
	return 1;
    }
    for (p2 = dat, q2 = p2 + 1, j = 0; *q2 ; p2++, q2++, j++) {
	for (p = *p2, q = *q2, i = 0; p < q; p++, i++) {
	    *p = 10 * j + i;
	}
    }
    printf("dat[1][1] = %f\n", dat[1][1]);
    printf("dat[9][9] = %f\n", dat[9][9]);
    printf("dat[jmax-1][imax-1] = %f\n", dat[jmax-1][imax-1]);
    freef2(dat);
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
echo This should produce a warning about failure to allocate dat.
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
echo This should produce a warning about failure to allocate dat.
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
echo This should produce a warning about failure to allocate dat.
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

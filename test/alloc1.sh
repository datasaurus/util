#!/bin/sh
#
# This script tests the allocators defined in src/alloc.c
#
# Copyright (c) 2008 Gordon D. Carrie
#
# Licensed under the Open Software License version 3.0
#
# Please send feedback to user0@tkgeomap.org
#
# $Id: alloc1.sh,v 1.5 2008/11/10 05:24:34 gcarrie Exp $
#
########################################################################

# This is the remove command.  Change this to : to retain intermediate results.

RM='rm -f'

$RM alloc1.out

# Here is the source code for the driver application.
# It allocates some memory, and then frees it.

cat > alloc1.c << END
#include <stdio.h>
#include <alloc.h>

int main(void)
{
    size_t i;
    float *x1, *x2, *x3;

    i = 1000;
    x1 = CALLOC(i, sizeof(float));
    if ( !x1 ) {
	fprintf(stderr, "Could not allocate x1.\n");
    }
    FREE(x1);

    x2 = MALLOC(i * sizeof(float));
    if ( !x2 ) {
	fprintf(stderr, "Could not allocate x2.\n");
    }
    FREE(x2);

    x3 = CALLOC(i, sizeof(float));
    if ( !x3 ) {
	fprintf(stderr, "Could not allocate x3.\n");
    }
    i = 2000;
    x3 = REALLOC(x3, i * sizeof(float));
    if ( !x3 ) {
	fprintf(stderr, "Could not reallocate x3.\n");
    }
    FREE(x3);

    return 0;
}
END

echo test1: building and running alloc1
cc -Isrc -o alloc1 src/alloc.c alloc1.c
echo Starting test1
alloc1
echo Done with test1
echo ""
$RM alloc1

echo test2: building and running alloc1 with memory trace.
echo An account of allocations and calls to free should appear on terminal
export MEM_DEBUG=2
cc -Isrc -o alloc1 src/alloc.c alloc1.c
echo Starting test2
alloc1
echo Done with test2
echo ""
$RM alloc1
unset MEM_DEBUG

echo test3: building and running alloc1 with memory trace.
echo An account of allocations and calls to free should appear in alloc1.out
export MEM_DEBUG=alloc1.out
cc -Isrc -o alloc1 src/alloc.c alloc1.c
echo Starting test3
alloc1
echo Here are the contents of alloc1.out
cat alloc1.out
echo Done with test3
echo ""
$RM alloc1 alloc1.out
unset MEM_DEBUG

echo test4: building and running alloc1.
echo Sending memory trace to findleaks, which should not find anything.
export MEM_DEBUG=2
cc -Isrc -o alloc1 src/alloc.c alloc1.c
echo Starting test4
alloc1 2>&1 | src/findleaks
echo Done with test4
echo ""
$RM alloc1
unset MEM_DEBUG

echo test5: building and running alloc1.
echo Sending memory trace to an unusable file.
echo There should be no diagnostic output, only a warning.
export MEM_DEBUG=alloc1.out
cc -Isrc -o alloc1 src/alloc.c alloc1.c
touch alloc1.out
chmod 444 alloc1.out
echo Starting test5
alloc1
echo Done with test5
echo ""
chmod 644 alloc1.out
$RM alloc1 alloc1.out
unset MEM_DEBUG

echo test6: simulate allocation failure in alloc1
echo This should produce a warning about failure to allocate x3.
export MEM_FAIL="alloc1.c:22"
cc -Isrc -o alloc1 src/alloc.c alloc1.c
echo Starting test6
alloc1
echo Done with test6
echo ""
$RM alloc1
unset MEM_FAIL

$RM alloc1.c

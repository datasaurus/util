#!/bin/sh
#
#- alloc1.sh --
#-	This script tests the allocators defined in src/alloc.c
#-	It creates and frees some memory while checking for leaks.
#-
# Copyright (c) 2008 Gordon D. Carrie
# Licensed under the Open Software License version 3.0
#
# Please send feedback to user0@tkgeomap.org
#
# $Id: alloc1.sh,v 1.9 2008/11/27 05:42:36 gcarrie Exp $
#
########################################################################

# This is the remove command.  Change this to : to retain intermediate results.

RM=${RM:-'rm -f'}

CC="cc"
CFLAGS="-g -Wall -Wmissing-prototypes"

# Here is the source code for the driver application.
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

if ! $CC $CFLAGS -Isrc -o alloc1 src/alloc.c alloc1.c
then
    echo "Could not compile the test application"
    exit 1
fi

echo test1: building and running alloc1
echo Starting test1
alloc1
echo Done with test1
echo ""

echo test2: building and running alloc1 with memory trace.
echo An account of allocations and calls to free should appear on terminal
export MEM_DEBUG=2
echo Starting test2
alloc1
echo Done with test2
echo ""
unset MEM_DEBUG

echo test3: building and running alloc1 with memory trace.
echo An account of allocations and calls to free should appear in alloc1.out
export MEM_DEBUG=alloc1.out
echo Starting test3
alloc1
echo Here are the contents of alloc1.out
echo The output should look like that from test2, although the addresses are
echo probably different.
cat alloc1.out
echo Done with test3
echo ""
$RM alloc1.out
unset MEM_DEBUG

echo test4: building and running alloc1.
echo Sending memory trace to findleaks, which should not find anything.
export MEM_DEBUG=2
echo Starting test4
if alloc1 2>&1 | src/findleaks
then
    echo findleaks found leaks!
else
    echo findleaks did not find any leaks.
fi
echo Done with test4
echo ""
unset MEM_DEBUG

echo test5: building and running alloc1.
echo Sending memory trace to an unwritable file.
echo There should be no diagnostic output, only a warning.
export MEM_DEBUG=alloc1.out
touch alloc1.out
chmod 444 alloc1.out
echo Starting test5
alloc1
echo Done with test5
echo ""
chmod 644 alloc1.out
$RM alloc1.out
unset MEM_DEBUG

echo test6: simulate allocation failures in alloc1
echo Each sub-test should produce a warnings about failure to allocate x3.
echo Starting test6
for n in `egrep -n 'MALLOC|CALLOC|REALLOC' alloc1.c | sed 's/:.*//'`
do
    echo "Simulating allocation failure at alloc1.c:$n"
    export MEM_FAIL="alloc1.c:$n"
    alloc1
    unset MEM_FAIL
done
echo Done with test6
echo ""

$RM alloc1.c alloc1

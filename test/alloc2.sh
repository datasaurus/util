#!/bin/sh
#
#- alloc2.sh --
#-	This script runs a test application that leaks memory.
#-
# Copyright (c) 2008 Gordon D. Carrie
# Licensed under the Open Software License version 3.0
#
# Please send feedback to dev0@trekix.net
#
# $Id: alloc2.sh,v 1.9 2008/11/27 05:50:55 gcarrie Exp $
#
########################################################################

FINDLEAKS=src/findleaks
CC="cc"
CFLAGS="-g -Wall -Wmissing-prototypes"

# Set RM to : to save intermediate files
RM=${RM:-'rm -f'}

# Here is the source code for the driver application.
# It allocates some memory, and then fails to free it.

cat > alloc2.c << END
#include <alloc.h>

int main(void)
{
    size_t i;
    float *x1, *x2, *x3;

    i = 1000;
    x1 = CALLOC(i, sizeof(float));
    FREE(x1);

    x2 = MALLOC(i * sizeof(float));
    FREE(x2);

    x3 = CALLOC(i, sizeof(float));
    i = 2000;
    x3 = REALLOC(x3, i * sizeof(float));

    return 0;
}
END

if ! $CC $CFLAGS -Isrc -o alloc2 src/alloc.c alloc2.c
then
    echo "Could not compile the test application"
    exit 1
fi

# Run the tests

echo test1: building and running alloc2
echo Starting test1
alloc2
echo Done with test1
echo ""

echo test2: building and running alloc2 with memory trace.
echo An account of allocations and calls to free should appear on terminal
export MEM_DEBUG=2
echo Starting test2
alloc2
echo Done with test2
echo ""
unset MEM_DEBUG

echo test3: building and running alloc2.
echo Sending memory trace to findleaks, which should report a leak.
export MEM_DEBUG=2
echo Starting test3
if alloc2 2>&1 | $FINDLEAKS
then
    echo Program leaks!
else
    echo ERROR: Failed to find memory leaks!
fi
echo Done with test3
echo ""
unset MEM_DEBUG

$RM alloc2.c

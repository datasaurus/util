#!/bin/sh
#
#- alloc2.sh --
#-	This script tests the allocators defined in src/alloc.c
#-	and script src/chkalloc.  It creates runs a test application
#-	that leaks memory.
#-
# Copyright (c) 2008 Gordon D. Carrie
# Licensed under the Open Software License version 3.0
#
# Please send feedback to dev0@trekix.net
#
# $Id: alloc2.sh,v 1.16 2008/12/16 22:48:10 gcarrie Exp $
#
########################################################################

echo "
alloc2.sh --

This script tests the allocators defined in src/alloc.c and script src/chkalloc.
See alloc (3) and chkalloc (1).

The script creates a test program that intentionally fails to free
memory that it allocates.

Usage suggestions:
./alloc1.sh 2>&1 | less
To save temporary files:
env RM=: ./alloc1.sh 2>&1 | less

Copyright (c) 2008 Gordon D. Carrie
Licensed under the Open Software License version 3.0

################################################################################
"

CHKALLOC=src/chkalloc
if ! test -x $CHKALLOC
then
    echo "No executable named $CHKALLOC"
    exit 1
fi

# Set RM to : in environment to save temporary files.
RM=${RM:-'rm -f'}

FINDLEAKS=src/findleaks
CC="cc"
CFLAGS="-g -Wall -Wmissing-prototypes"

# Here is the source code for the driver application.
cat > alloc2.c << END
#include <alloc.h>

int main(void)
{
    size_t i;
    float *x1, *x2, *x3;

    i = 1000;
    x1 = CALLOC(i, sizeof(float));
    FREE(x1);

    x2 = CALLOC(i, sizeof(float));
    i = 2000;
    x3 = REALLOC(x2, i * sizeof(float));

    alloc_clean();
    return 0;
}
END

if ! $CC $CFLAGS -Isrc -o alloc2 src/alloc.c alloc2.c
then
    echo "Could not compile the test application"
    exit 1
fi

# Run the tests

echo "test1: normal run of alloc2."
result1=success
if ./alloc2
then
    echo "alloc2 ran."
else
    echo "alloc2 failed."
    result1=fail
fi
echo "test1 result = $result1
Done with test1

################################################################################
"

echo "test2: running alloc2 with memory trace."
result2=success
export MEM_DEBUG=2
if ./alloc2 2>&1 | $CHKALLOC
then
    echo "chkalloc failed to find a leak"
    result2=fail
else
    status=$?
    if [ $status -eq 1 ]
    then
	echo "chkalloc found leak (as it should have)"
    elif [ $status -eq 2 ]
    then
	echo "chkalloc did not receive input"
	result2=fail
    else
	echo "chkalloc returned unknown value $status"
	result2=fail
    fi
fi
unset MEM_DEBUG
echo "test2 result = $result2
Done with test2

################################################################################
"

echo "Summary:
test1 result = $result1
test2 result = $result2
"

$RM alloc2.c alloc2

echo "$0 all done.

################################################################################
################################################################################
"

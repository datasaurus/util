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
# $Id: alloc2.sh,v 1.11 2008/12/07 21:45:15 gcarrie Exp $
#
########################################################################

echo "
alloc2.sh --

This script tests the allocators defined in src/alloc.c and the findleaks
application.  See alloc (3) and findleaks (1) for more information.

The script creates a test program that allocates and frees memory using
functions in alloc.c.  The test program intentionally fails to free
memory that it allocates.  The failures should be apparent in output from
the program and findleaks.  You must read the output and check for error
messages and inconsistencies.

The script puts source code for the test program into a source file
named alloc2.c and creates an executable named alloc2.  The program
files are normally deleted when the script exits.  To preserve
program and temporary files for post mortem troubleshooting, set
RM in the environment to a command that does not delete anything,
e.g. ':'.

Usage suggestions:
./alloc2.sh 2>&1 | less
env RM=: ./alloc2.sh 2>&1 | less

Copyright (c) 2008 Gordon D. Carrie
Licensed under the Open Software License version 3.0

--------------------------------------------------------------------------------
"

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

    return 0;
}
END

if ! $CC $CFLAGS -Isrc -o alloc2 src/alloc.c alloc2.c
then
    echo "Could not compile the test application"
    exit 1
fi

# Run the tests

echo "test1: This is a dry run alloc2.  There should not be any output,
error messages, or crashes.
Starting test1"
alloc2
echo "Done with test1

--------------------------------------------------------------------------------
"

echo "test2: building and running alloc2 with memory trace.
An account of allocations and calls to free should appear on terminal
the terminal.  The format of this account is described in alloc (3).
Starting test2"
export MEM_DEBUG=2
alloc2
unset MEM_DEBUG
echo "Done with test2

--------------------------------------------------------------------------------
"

echo "test3: building and running alloc2.
Sending memory trace to findleaks, which should report a leak.
Starting test3"
export MEM_DEBUG=2
if alloc2 2>&1 | $FINDLEAKS
then
    echo Program leaks!
else
    echo ERROR: Failed to find memory leaks!
fi
unset MEM_DEBUG
echo "Done with test3

--------------------------------------------------------------------------------
"

$RM alloc2.c

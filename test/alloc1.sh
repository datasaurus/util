#!/bin/sh
#
#- alloc1.sh --
#-	This script tests the allocators defined in src/alloc.c
#-	It creates and frees some memory while checking for leaks.
#-
# Copyright (c) 2008 Gordon D. Carrie
# Licensed under the Open Software License version 3.0
#
# Please send feedback to dev0@trekix.net
#
# $Id: alloc1.sh,v 1.11 2008/12/02 17:19:39 gcarrie Exp $
#
########################################################################

echo "
alloc1.sh --

This script tests the allocators defined in src/alloc.c.  See
alloc (3) for information about these functions.  The script creates
a test program that allocates and frees memory using functions in alloc.c.
It checks for leaks and imposes various failures.  Output varies with
system.  You must read the output and check for error messages and
inconsistencies.

The script puts source code for the test program into a source file
named alloc1.c and creates an executable named alloc1.  Some output
is also saved into temporary files.  These program and temporary
files are normally deleted when the script exits.  To preserve
program and temporary files for post mortem troubleshooting, set
RM in the environment to a command that does not delete anything,
e.g. ':'.

Usage suggestions:
./alloc1.sh 2>&1 | less
env RM=: ./alloc1.sh 2>&1 | less

Copyright (c) 2008 Gordon D. Carrie Licensed under the Open Software
License version 3.0

--------------------------------------------------------------------------------
"

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

echo "test1: building and running alloc1.  There should be no output,
error messages or crashes.
Starting test1"
alloc1
echo "Done with test1

--------------------------------------------------------------------------------
"

echo "test2: building and running alloc1 with memory trace, i.e. MEM_DEBUG
is set.  account of allocations and calls to free should appear on
the terminal.  The format of this account is described in alloc (3).
Starting test2"
export MEM_DEBUG=2
alloc1
unset MEM_DEBUG
echo "Done with test2

--------------------------------------------------------------------------------
"

echo "test3: building and running alloc1 with memory trace going to a
file.  An account of allocations and calls to free should appear
in alloc3.out
Starting test3"
export MEM_DEBUG=alloc3.out
alloc1
unset MEM_DEBUG
echo "Here are the contents of alloc3.out.  The output should look like that
from test2, although the addresses are probably different."
cat alloc3.out
$RM alloc3.out
echo "Done with test3

--------------------------------------------------------------------------------
"

echo "test4: building and running alloc1 with memory trace and leak
checking.  This time the memory trace is being piped to findleaks,
which will look for allocations that are never freed.  See findleaks
(1).  findleaks should not find any leaks.
Starting test4"
export MEM_DEBUG=2
if alloc1 2>&1 | src/findleaks
then
    echo "findleaks found leaks!"
else
    echo "findleaks did not find any leaks."
fi
unset MEM_DEBUG
echo "Done with test4

--------------------------------------------------------------------------------
"

echo "test5: building and running alloc1 with memory trace.  Sending
memory trace to an unwritable file.  There should be a message
announcing failure to produce diagnostic output.
Starting test5"
export MEM_DEBUG=alloc5.out
touch alloc5.out
chmod 444 alloc5.out
alloc1
chmod 644 alloc5.out
$RM alloc5.out
unset MEM_DEBUG
echo "Done with test5

--------------------------------------------------------------------------------
"

echo "test6: simulate allocation failures in alloc1 This test will run
alloc1 several times with the MEM_FAIL environment variable set.
Each time it will impose an apparent allocation failure at a different
place in the program.  Each time it runs the program should report the
failure and exit gracefully.
Starting test6"
for n in `egrep -n 'MALLOC|CALLOC|REALLOC' alloc1.c | sed 's/:.*//'`
do
    echo "Running alloc1, simulating allocation failure at alloc1.c:$n"
    export MEM_FAIL="alloc1.c:$n"
    alloc1
    unset MEM_FAIL
done
echo "Done with test6

--------------------------------------------------------------------------------
"

$RM alloc1.c alloc1
echo "$0 all done."

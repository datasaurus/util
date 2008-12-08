#!/bin/sh
#
#- alloc2f_1.sh --
#-	This script tests the allocators defined in src/alloc2f.c
#-	It allocates, accesses, and then frees a two dimensional array.
#-
# Copyright (c) 2008 Gordon D. Carrie
# Licensed under the Open Software License version 3.0
#
# Please send feedback to dev0@trekix.net
#
# $Id: alloc2f_1.sh,v 1.17 2008/12/05 20:57:17 gcarrie Exp $
#
########################################################################

echo "
alloc2f_1.sh --

This script tests the functions defined in src/alloc2f.c.
See alloc2f (3) for information on these functions.

The script temporarily creates a source file named alloc2f.c and executable
named alloc2f. alloc2f allocates, accesses, and then frees a two dimensional
array.  The script checks for normal output, memory leaks, and proper error
handling if an allocation fails.  The program files are normally deleted when
the script exits.  To preserve program and temporary files for post mortem
troubleshooting, set RM in the environment to a command that does not delete
anything, e.g. ':'.

Usage suggestions:
./alloc2f_1.sh 2>&1 | less
env RM=: ./alloc2f_1.sh 2>&1 | less

Copyright (c) 2008 Gordon D. Carrie
Licensed under the Open Software License version 3.0

--------------------------------------------------------------------------------
"

RM=${RM:-'rm -f'}

# Array in the test application will have dimensions JMAX by IMAX.
# Set these in the environment if they are too big.
JMAX=${JMAX:-"7907"}
IMAX=${IMAX:-"7919"}

CC="cc"
CFLAGS="-g -Wall -Wmissing-prototypes"

# Here is the source code for the driver application.
cat > alloc2f_1.c << END
#include <stdio.h>
#include <err_msg.h>
#include <alloc2f.h>

int main(int argc, char *argv[])
{
    long jmax, imax;
    long j, i;
    float **dat = NULL, **p2, *p;

    jmax = ${JMAX};
    imax = ${IMAX};
    fprintf(stderr, "Creating a %ld by %ld array (%.4g MB)\n",
	    jmax, imax, ((double)jmax * (double)imax * sizeof(float)) / 1048576.0);

    /* Create array and access with conventional indexing */
    dat = calloc2f(jmax, imax);
    if ( !dat ) {
	fprintf(stderr, "%s: Could not allocate dat.\n%s", argv[0], err_get());
	return 1;
    }
    for (j = 0; j < jmax; j++) {
	for (i = 0; i < imax; i++) {
	    dat[j][i] = 10 * j + i;
	}
    }
    printf("dat[1][1] = %8.1f\n", dat[1][1]);
    printf("dat[9][9] = %8.1f\n", dat[9][9]);
    printf("dat[jmax-1][imax-1] = %8.1f\n", dat[jmax-1][imax-1]);
    free2f(dat);

    /* Create array and access with pointers */
    dat = calloc2f(jmax, imax);
    if ( !dat ) {
	fprintf(stderr, "%s: Could not allocate dat.\n%s", argv[0], err_get());
	return 1;
    }
    for (p2 = dat; p2[1]; p2++) {
	j = p2 - dat;
	for (p = p2[0]; p < p2[1]; p++) {
	    i = p - *p2;
	    *p = 10 * j + i;
	}
    }
    printf("dat[1][1] = %8.1f\n", dat[1][1]);
    printf("dat[9][9] = %8.1f\n", dat[9][9]);
    printf("dat[jmax-1][imax-1] = %8.1f\n", dat[jmax-1][imax-1]);
    free2f(dat);
    return 0;
}
END

# Standard output from the test program should match contents of file correct.
(
    printf 'dat[1][1] = %8.1f\n' 11.0
    printf 'dat[9][9] = %8.1f\n' 99.0
    printf 'dat[jmax-1][imax-1] = %8.1f\n' `expr 10 \* \( $JMAX - 1 \) + $IMAX - 1`
    printf 'dat[1][1] = %8.1f\n' 11.0
    printf 'dat[9][9] = %8.1f\n' 99.0
    printf 'dat[jmax-1][imax-1] = %8.1f\n' `expr 10 \* \( $JMAX - 1 \) + $IMAX - 1`
) > correct

echo "building alloc2f_1"
SRC="alloc2f_1.c src/alloc2f.c src/alloc.c src/err_msg.c"
if $CC $CFLAGS -Isrc -o alloc2f_1 $SRC
then
    echo "success"
else
    echo "Build failed."
    exit 1
fi
echo ""

echo "test1: running alloc2f_1"
echo ""
echo "Starting test1"
echo "----------------------------------------------------------------"
alloc2f_1 | tee attempt
echo "----------------------------------------------------------------"
if diff correct attempt
then
    echo "alloc2f_1 produced correct output."
else
    echo "alloc2f_1 produced bad output!"
fi
$RM attempt
echo "Done with test1"
echo ""

echo "test2: running allocf1 with memory trace"
echo "An account of allocations and calls to free should appear on terminal."
echo "All other output will be discarded."
echo "Starting test2"
export MEM_DEBUG=2
echo "----------------------------------------------------------------"
alloc2f_1 > /dev/null
echo "----------------------------------------------------------------"
unset MEM_DEBUG
echo "Done with test2"
echo ""

echo "test3: running allocf1 with memory trace"
echo "Sending memory trace to findleaks, which should not find anything."
export MEM_DEBUG=2
echo "Starting test3"
if alloc2f_1 2>&1 > /dev/null | src/findleaks
then
    echo "Program leaks!"
else
    echo "No leaks"
fi
echo "Done with test3"
echo ""
unset MEM_DEBUG

# The next tests simulate memory failures at lines where src/alloc2f.c
# calls CALLOC.  The MEM_FAIL specifications are stored in ll.
echo "The following tests impose simulated memory failures."
ll=""
printf "Will simulate memory failure at:\n"
for f in $SRC
do
    l=`egrep -n 'MALLOC|CALLOC|REALLOC' $f | sed "s!^\([0-9][0-9]*\):.*!${f}:\1!"`
    printf "%s\n" $l
    ll="$ll $l"
done
printf "\n"

echo "test4: simulate every possible allocation failure in alloc2f_1"
echo "This should produce several warnings about failure to allocate dat."
echo ""
for l in $ll
do
    export MEM_FAIL=$l
    echo "    Starting test4 simulating failure at $l"
    echo "    ------------------------------------------------------------"
    alloc2f_1 2>&1 | sed 's/^/    /'
    echo "    ------------------------------------------------------------"
    echo "    Done with test4 simulating failure at $l"
    echo ""
    unset MEM_FAIL
done
echo ""
echo "All done with test4"
echo ""

echo "test5: repeat test4 with memory tracing."
echo "alloc2f_1 should exit gracefully without leaking."
echo ""
export MEM_DEBUG=3
for l in $ll
do
    export MEM_FAIL=$l
    echo "    Starting test5 simulating failure at $l"
    if alloc2f_1 3>&1 > /dev/null 2>&1 | src/findleaks
    then
	echo "Program leaks!"
    else
	echo "    No leaks"
    fi
    echo "    Done with test5 simulating failure at $l"
    echo ""
    unset MEM_FAIL
done
unset MEM_DEBUG
echo "All done with test5"

$RM alloc2f_1.c alloc2f_1 correct

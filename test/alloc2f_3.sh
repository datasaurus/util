#!/bin/sh
#
#- alloc2f_3.sh --
#-	This script tests the allocators defined in src/alloc2f.c
#-	It is like alloc2f_3.sh, except that it tests a small, one by one
#-	array.
#-
# Copyright (c) 2008 Gordon D. Carrie
# Licensed under the Open Software License version 3.0
#
# Please send feedback to dev0@trekix.net
#
# $Id: $
#
########################################################################

# Set RM to : to save intermediate files
RM=${RM:-'rm -f'}

CC="cc"
CFLAGS="-g -Wall -Wmissing-prototypes"

# Here is the source code for the driver application.
cat > alloc2f_3.c << END
#include <stdio.h>
#include <err_msg.h>
#include <alloc2f.h>

int main(int argc, char *argv[])
{
    long jmax, imax;
    long j, i;
    float **dat = NULL, **p2, *p;

    jmax = 1;
    imax = 1;
    fprintf(stderr, "Creating a %ld by %ld array\n", jmax, imax);

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
    printf("dat[jmax-1][imax-1] = %8.1f\n", dat[jmax-1][imax-1]);
    free2f(dat);
    return 0;
}
END

(
    printf 'dat[jmax-1][imax-1] =      0.0\n'
    printf 'dat[jmax-1][imax-1] =      0.0\n'
) \
> correct

echo "building alloc2f_3"
SRC="alloc2f_3.c src/alloc2f.c src/alloc.c src/err_msg.c"
if $CC $CFLAGS -Isrc -o alloc2f_3 $SRC
then
    echo "success"
else
    echo "Build failed."
    exit 1
fi
echo ""

echo "test1: running alloc2f_3"
echo ""
echo "Starting test1"
echo "----------------------------------------------------------------"
alloc2f_3 | tee attempt
echo "----------------------------------------------------------------"
if diff correct attempt
then
    echo "alloc2f_3 produced correct output."
else
    echo "alloc2f_3 produced bad output!"
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
alloc2f_3 > /dev/null
echo "----------------------------------------------------------------"
unset MEM_DEBUG
echo "Done with test2"
echo ""

echo "test3: running allocf1 with memory trace"
echo "Sending memory trace to findleaks, which should not find anything."
export MEM_DEBUG=2
echo "Starting test3"
if alloc2f_3 2>&1 > /dev/null | src/findleaks
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

echo "test4: simulate every possible allocation failure in alloc2f_3"
echo "This should produce several warnings about failure to allocate dat."
echo ""
for l in $ll
do
    export MEM_FAIL=$l
    echo "    Starting test4 simulating failure at $l"
    echo "    ------------------------------------------------------------"
    alloc2f_3 2>&1 | sed 's/^/    /'
    echo "    ------------------------------------------------------------"
    echo "    Done with test4 simulating failure at $l"
    echo ""
    unset MEM_FAIL
done
echo ""
echo "All done with test4"
echo ""

echo "test5: repeat test4 with memory tracing."
echo "alloc2f_3 should exit gracefully without leaking."
echo ""
export MEM_DEBUG=3
for l in $ll
do
    export MEM_FAIL=$l
    echo "    Starting test5 simulating failure at $l"
    if alloc2f_3 3>&1 > /dev/null 2>&1 | src/findleaks
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

$RM alloc2f_3.c alloc2f_3 correct

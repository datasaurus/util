#!/bin/sh
#
#- alloc3f_1.sh --
#-	This script tests the allocators defined in src/alloc3f.c
#-	It is like alloc3f_1.sh, except that it tests a small, one by one by one
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
cat > alloc3f_1.c << END
#include <stdio.h>
#include <err_msg.h>
#include <alloc3f.h>

int main(int argc, char *argv[])
{
    long kmax, jmax, imax;
    long k, j, i;
    float ***dat = NULL, ***p3, **p2, *p;

    kmax = 1;
    jmax = 1;
    imax = 1;
    fprintf(stderr, "Creating a %ld by %ld by %ld array (%.1f MB)\n",
	    kmax, jmax, imax, (kmax * jmax * imax * sizeof(float)) / 1048576.0);

    /* Create array and access with conventional indexing */
    dat = calloc3f(kmax, jmax, imax);
    if ( !dat ) {
	fprintf(stderr, "Could not allocate dat\n%s\n", err_get());
	return 1;
    }
    for (k = 0; k < kmax; k++) {
	for (j = 0; j < jmax; j++) {
	    for (i = 0; i < imax; i++) {
		dat[k][j][i] = 100 * k + 10 * j + i;
	    }
	}
    }
    printf("dat[kmax-1][jmax-1][imax-1] = %8.1f\n", dat[kmax-1][jmax-1][imax-1]);
    free3f(dat);
    
    /* Create array and access with pointers */
    dat = calloc3f(kmax, jmax, imax);
    if ( !dat ) {
        fprintf(stderr, "%s: Could not allocate dat.\n%s", argv[0], err_get());
        return 1;
    }
    for (p3 = dat; p3[1]; p3++) {
	k = p3 - dat;
	for (p2 = p3[0]; p2 < p3[1]; p2++) {
	    j = p2 - *p3;
	    for (p = p2[0]; p < p2[1]; p++) {
		i = p - *p2;
		*p = 100 * k + 10 * j + i;
	    }
	}
    }
    printf("dat[kmax-1][jmax-1][imax-1] = %8.1f\n", dat[kmax-1][jmax-1][imax-1]);
    free3f(dat);
    return 0;
}
END

# Standard output from the test program should match contents of file correct.
(
    printf 'dat[kmax-1][jmax-1][imax-1] =      0.0\n'
    printf 'dat[kmax-1][jmax-1][imax-1] =      0.0\n'
) > correct

echo "building alloc3f_1"
SRC="alloc3f_1.c src/alloc3f.c src/alloc.c src/err_msg.c"
if $CC $CFLAGS -Isrc -o alloc3f_1 $SRC
then
    echo "success"
else
    echo "Build failed."
    exit 1
fi

echo test1: running alloc3f_1
echo ""
echo Starting test1
echo "----------------------------------------------------------------"
alloc3f_1 | tee attempt
echo "----------------------------------------------------------------"
if diff correct attempt
then
    echo "test program produced correct output"
else
    echo "test program failed!"
fi
$RM attempt
echo Done with test1
echo ""

echo test2: running allocf1 with memory trace.
echo An account of allocations and calls to free should appear on terminal
echo "All other output will be discarded."
echo Starting test2
export MEM_DEBUG=2
echo "----------------------------------------------------------------"
alloc3f_1 > /dev/null
echo "----------------------------------------------------------------"
unset MEM_DEBUG
echo Done with test2
echo ""

echo test3: running alloc3f_1 with memory trace.
echo Sending memory trace to findleaks, which should not find anything.
export MEM_DEBUG=2
echo Starting test3
if alloc3f_1 2>&1 > /dev/null | src/findleaks
then
    echo "Program leaks!"
else
    echo "No leaks"
fi
echo Done with test3
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

echo "test4: simulate every possible allocation failure in alloc3f_1"
echo "This should produce several warnings about failure to allocate dat."
echo ""
for l in $ll
do
    export MEM_FAIL=$l
    echo "    Starting test4 simulating failure at $l"
    echo "    ------------------------------------------------------------"
    alloc3f_1 2>&1 | sed 's/^/    /'
    echo "    ------------------------------------------------------------"
    echo "    Done with test4 simulating failure at $l"
    echo ""
    unset MEM_FAIL
done
echo ""
echo "All done with test4"
echo ""

echo "test5: repeat test4 with memory tracing."
echo "alloc3f_1 should exit gracefully without leaking."
echo ""
export MEM_DEBUG=3
for l in $ll
do
    export MEM_FAIL=$l
    echo "    Starting test5 simulating failure at $l"
    if alloc3f_1 3>&1 > /dev/null 2>&1 | src/findleaks
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

$RM alloc3f_1.c alloc3f_1 correct

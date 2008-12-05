#!/bin/sh
#
#- alloc4f_1.sh --
#-	This script tests the allocators defined in src/alloc4f.c
#-	It allocates, accesses, and then frees a four dimensional array.
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

# Array in the test application will have dimensions KMAX by JMAX by IMAX.
# Set these to something substantial but not overwhelming.
LMAX=${LMAX:-"79"}
KMAX=${KMAX:-"83"}
JMAX=${JMAX:-"89"}
IMAX=${IMAX:-"97"}

CC="cc"
CFLAGS="-g -Wall -Wmissing-prototypes"

# Here is the source code for the driver application.
cat > alloc4f_1.c << END
#include <stdio.h>
#include <err_msg.h>
#include <alloc4f.h>

int main(int argc, char *argv[])
{
    long lmax, kmax, jmax, imax;
    long l, k, j, i;
    float ****dat = NULL, ****p4, ***p3, **p2, *p;

    lmax = 79;
    kmax = 83;
    jmax = 89;
    imax = 97;
    fprintf(stderr, "Creating a %ld by %ld by %ld by %ld array (%.1f MB)\n",
	    lmax, kmax, jmax, imax,
	    (lmax * kmax * jmax * imax * sizeof(float)) / 1048576.0);

    /* Create array and access with conventional indexing */
    dat = calloc4f(lmax, kmax, jmax, imax);
    if ( !dat ) {
	fprintf(stderr, "Could not allocate dat\n%s\n", err_get());
	return 1;
    }
    for (l = 0; l < lmax; l++) {
	for (k = 0; k < kmax; k++) {
	    for (j = 0; j < jmax; j++) {
		for (i = 0; i < imax; i++) {
		    dat[l][k][j][i] = 1000 * l + 100 * k + 10 * j + i;
		}
	    }
	}
    }
    printf("dat[1][1][1][1] = %8.1f\n", dat[1][1][1][1]);
    printf("dat[9][9][9][9] = %8.1f\n", dat[9][9][9][9]);
    printf("dat[lmax-1][kmax-1][jmax-1][imax-1] = %8.1f\n",
	    dat[lmax-1][kmax-1][jmax-1][imax-1]);
    free4f(dat);
    
    /* Create array and access with pointers */
    dat = calloc4f(lmax, kmax, jmax, imax);
    if ( !dat ) {
        fprintf(stderr, "%s: Could not allocate dat.\n%s", argv[0], err_get());
        return 1;
    }
    for (p4 = dat; p4[1]; p4++) {
	l = p4 - dat;
	for (p3 = p4[0]; p3 < p4[1]; p3++) {
	    k = p3 - *p4;
	    for (p2 = p3[0]; p2 < p3[1]; p2++) {
		j = p2 - *p3;
		for (p = p2[0]; p < p2[1]; p++) {
		    i = p - *p2;
		    *p = 1000 * l + 100 * k + 10 * j + i;
		}
	    }
	}
    }
    printf("dat[1][1][1][1] = %8.1f\n", dat[1][1][1][1]);
    printf("dat[9][9][9][9] = %8.1f\n", dat[9][9][9][9]);
    printf("dat[lmax-1][kmax-1][jmax-1][imax-1] = %8.1f\n",
	    dat[lmax-1][kmax-1][jmax-1][imax-1]);
    free4f(dat);
    return 0;
}
END

# Standard output from the test program should match contents of file correct.
(
    printf 'dat[1][1][1][1] = %8.1f\n' 1111.0
    printf 'dat[9][9][9][9] = %8.1f\n' 9999.0
    printf 'dat[lmax-1][kmax-1][jmax-1][imax-1] = %8.1f\n' \
`expr 1000 \* \( $LMAX - 1 \) + 100 \* \( $KMAX - 1 \) + 10 \* \( $JMAX - 1 \) + $IMAX - 1`
    printf 'dat[1][1][1][1] = %8.1f\n' 1111.0
    printf 'dat[9][9][9][9] = %8.1f\n' 9999.0
    printf 'dat[lmax-1][kmax-1][jmax-1][imax-1] = %8.1f\n' \
`expr 1000 \* \( $LMAX - 1 \) + 100 \* \( $KMAX - 1 \) + 10 \* \( $JMAX - 1 \) + $IMAX - 1`
) > correct

echo "building alloc4f_1"
SRC="alloc4f_1.c src/alloc4f.c src/alloc.c src/err_msg.c"
if $CC $CFLAGS -Isrc -o alloc4f_1 $SRC
then
    echo "success"
else
    echo "Build failed."
    exit 1
fi

echo test1: running alloc4f_1
echo ""
echo Starting test1
echo "----------------------------------------------------------------"
alloc4f_1 | tee attempt
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
alloc4f_1 > /dev/null
echo "----------------------------------------------------------------"
unset MEM_DEBUG
echo Done with test2
echo ""

echo test3: running alloc4f_1 with memory trace.
echo Sending memory trace to findleaks, which should not find anything.
export MEM_DEBUG=2
echo Starting test3
if alloc4f_1 2>&1 > /dev/null | src/findleaks
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

echo "test4: simulate every possible allocation failure in alloc4f_1"
echo "This should produce several warnings about failure to allocate dat."
echo ""
for l in $ll
do
    export MEM_FAIL=$l
    echo "    Starting test4 simulating failure at $l"
    echo "    ------------------------------------------------------------"
    alloc4f_1 2>&1 | sed 's/^/    /'
    echo "    ------------------------------------------------------------"
    echo "    Done with test4 simulating failure at $l"
    echo ""
    unset MEM_FAIL
done
echo ""
echo "All done with test4"
echo ""

echo "test5: repeat test4 with memory tracing."
echo "alloc4f_1 should exit gracefully without leaking."
echo ""
export MEM_DEBUG=3
for l in $ll
do
    export MEM_FAIL=$l
    echo "    Starting test5 simulating failure at $l"
    if alloc4f_1 3>&1 > /dev/null 2>&1 | src/findleaks
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

$RM alloc4f_1.c alloc4f_1 correct

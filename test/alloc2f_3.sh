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
# $Id: alloc2f_3.sh,v 1.19 2008/12/11 23:00:41 gcarrie Exp $
#
########################################################################

echo "
alloc2f_3.sh --

This script tests the functions defined in src/alloc2f.c.
See alloc2f (3) for information on these functions.

It is similar to alloc2f_1.sh, but tests with a small array.  It creates a test
application named alloc2f_3 that allocates, accesses, and frees a very small two
dimensional array, one element by one element.  It runs the application while
checking for memory leaks and evaluating responses to variable simulated failures.

Usage suggestions:
./alloc2f_3.sh 2>&1 | less
To save temporary files:
env RM=: ./alloc2f_3.sh 2>&1 | less

Copyright (c) 2008 Gordon D. Carrie
Licensed under the Open Software License version 3.0

--------------------------------------------------------------------------------
"

# Set RM to : in environment to save temporary files.
RM=${RM:-'rm -f'}

CC="cc"
CFLAGS="-g -Wall -Wmissing-prototypes"

CHKALLOC=src/chkalloc
if ! test -x $CHKALLOC
then
    echo "No executable named $CHKALLOC"
    exit 1
fi

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

SRC="alloc2f_3.c src/alloc2f.c src/alloc.c src/err_msg.c"
if ! $CC $CFLAGS -Isrc -o alloc2f_3 $SRC
then
    echo "Build failed."
    exit 1
fi

echo "test1: normal run of alloc2f_3"
result1=success
(
    printf 'dat[jmax-1][imax-1] = %8.1f\n' 0.0
    printf 'dat[jmax-1][imax-1] = %8.1f\n' 0.0
) > correct1.out
if ./alloc2f_3 | diff correct1.out -
then
    echo "alloc2f_3 produced correct output."
else
    echo "alloc2f_3 produced bad output!"
    result1=fail
fi
$RM correct1.out
echo "test1 result = $result1
Done with test1

--------------------------------------------------------------------------------
"

echo "test2: running allocf1 with memory trace"
result2=success
export MEM_DEBUG=2
if ./alloc2f_3 2>&1 > /dev/null | $CHKALLOC
then
    echo "No leaks"
else
    echo "alloc2f_3 leaks!"
    result1=fail
fi
unset MEM_DEBUG
echo "test2 result = $result2
Done with test2

--------------------------------------------------------------------------------
"

# The next tests simulate memory failures at lines where source code
# invokes a memory allocator.  These lines are stored in ll, which will
# be assigned to MEM_FAIL in the tests.
#
# This test will not simulate failure in err_msg.c because the driver
# application does not allocate memory for error messages.
ll=""
printf "Will simulate memory failures at:\n"
for f in alloc2f_3.c src/alloc2f.c src/alloc.c
do
    l=`egrep -n 'MALLOC|CALLOC|REALLOC' $f | sed "s!^\([0-9][0-9]*\):.*!${f}:\1!"`
    printf "%s\n" $l
    ll="$ll $l"
done
printf "\n"

echo "test3: simulate allocation failures in alloc2f_3"
result3=success
for l in $ll
do
    export MEM_FAIL=$l
    if ./alloc2f_3 > /dev/null 2>&1
    then
	echo "alloc2f_3 ran normally when it should have failed at $MEM_FAIL"
	result4=fail
    else
	echo "alloc2f_3 failed as expected for failure at $MEM_FAIL"
    fi
    unset MEM_FAIL
done
echo "test3 result = $result3
All done with test3

--------------------------------------------------------------------------------
"

echo "test4: repeat test4 with memory tracing."
result4=success
export MEM_DEBUG=3
for l in $ll
do
    export MEM_FAIL=$l
    if ./alloc2f_3 3>&1 > /dev/null 2>&1 | $CHKALLOC
    then
	echo "alloc2f_3 exits without leaks when simulating failure at $MEM_FAIL"
    else
	status=$?
	if [ $status -eq 1 ]
	then
	    echo "alloc2f_3 leaks when simulating failure at $MEM_FAIL"
	elif [ $status -eq 2 ]
	then
	    printf "%s%s\n" "chkalloc did not receive input from alloc2f_3" \
		    " when simulating failure at $MEM_FAIL"
	    result4=fail
	else
	    echo "chkalloc returned unknown value $?"
	    result4=fail
	fi
    fi
    unset MEM_FAIL
done
unset MEM_DEBUG
echo "test4 result=$result4
All done with test4

--------------------------------------------------------------------------------
"

echo "Summary:
test1 result = $result1
test2 result = $result2
test3 result = $result3
test4 result = $result4
"

$RM alloc2f_3.c alloc2f_3

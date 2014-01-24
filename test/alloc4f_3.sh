#!/bin/sh
#
#- alloc4f_1.sh --
#-	This test application tests the allocators defined in src/alloc4f.c
#-	It is similar to alloc4f_1.sh, except that the process creates a
#-	small, one by one by one by one array.
#-
# Copyright (c) 2011, Gordon D. Carrie. All rights reserved.
# 
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# 
#     * Redistributions of source code must retain the above copyright
#     notice, this list of conditions and the following disclaimer.
#     * Redistributions in binary form must reproduce the above copyright
#     notice, this list of conditions and the following disclaimer in the
#     documentation and/or other materials provided with the distribution.
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
# A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
# HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
# SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
# TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
# PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
# LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
# NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
# Please send feedback to dev0@trekix.net
#
# $Revision: 1.23 $ $Date: 2011/11/28 16:11:23 $
#
########################################################################

echo "
alloc4f_3.sh --

This test application tests the functions defined in src/alloc4f.c.
See alloc4f (3) for information on these functions.

It is similar to alloc4f_1.sh, but tests with a small array.  It creates a test
application named alloc4f_3 that allocates, accesses, and frees a very small four
dimensional array.  The array is 1x1x1x1.  It runs the application while
checking for memory leaks and evaluating responses to various simulated failures.

Usage suggestions:
./alloc4f_3.sh 2>&1 | less
To save temporary files:
env RM=: ./alloc4f_3.sh 2>&1 | less

Copyright (c) 2008 Gordon D. Carrie
All rights reserved

################################################################################
"

# Set RM to : to save intermediate files
RM=${RM:-'rm -f'}

CC="cc -std=c99"
CFLAGS="-g -Wall -Wmissing-prototypes"
MSRC="alloc4f_3.c"
ASRC="$MSRC src/alloc4f.c src/alloc.c"
SRC="$ASRC src/err_msg.c"
EXEC="alloc4f_3"

CHKALLOC=src/chkalloc
if ! test -x $CHKALLOC
then
    echo "No executable named $CHKALLOC"
    exit 1
fi

# Here is the source code for the driver application.
cat > $MSRC << END
#include <stdio.h>
#include <err_msg.h>
#include <alloc.h>
#include <alloc4f.h>

int main(int argc, char *argv[])
{
    long lmax, kmax, jmax, imax;
    long l, k, j, i;
    float ****dat = NULL, ****p4, ***p3, **p2, *p;

    lmax = 1;
    kmax = 1;
    jmax = 1;
    imax = 1;
    fprintf(stderr, "Creating a %ld by %ld by %ld by %ld array\n",
	    lmax, kmax, jmax, imax);

    /* Create array and access with conventional indexing */
    dat = Calloc4F(lmax, kmax, jmax, imax);
    if ( !dat ) {
	fprintf(stderr, "Could not allocate dat\n%s\n", Err_Get());
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
    printf("dat[lmax-1][kmax-1][jmax-1][imax-1] = %8.1f\n",
	    dat[lmax-1][kmax-1][jmax-1][imax-1]);
    Free4F(dat);
    
    /* Create array and access with pointers */
    dat = Calloc4F(lmax, kmax, jmax, imax);
    if ( !dat ) {
        fprintf(stderr, "%s: Could not allocate dat.\n%s", argv[0], Err_Get());
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
    printf("dat[lmax-1][kmax-1][jmax-1][imax-1] = %8.1f\n",
	    dat[lmax-1][kmax-1][jmax-1][imax-1]);
    Free4F(dat);

    return 0;
}
END

# This is standard output from the test application.
(
    printf 'dat[lmax-1][kmax-1][jmax-1][imax-1] =      0.0\n'
    printf 'dat[lmax-1][kmax-1][jmax-1][imax-1] =      0.0\n'
) > ${EXEC}.out

# Build the test application
if ! $CC $CFLAGS -Isrc -o $EXEC $SRC
then
    echo "Build failed."
    exit 1
fi

# Run the tests
echo "test1: normal run of $EXEC"
result1=success
if ./$EXEC | diff ${EXEC}.out -
then
    echo "$EXEC produced correct output."
else
    echo "$EXEC produced bad output!"
    result1=fail
fi
$RM ${EXEC}.out
echo "test1 result = $result1
Done with test1

################################################################################
"

echo "test2: running allocf1 with memory trace"
result2=success
export MEM_DEBUG=2
if ./$EXEC 2>&1 > /dev/null | $CHKALLOC
then
    echo "No leaks"
else
    echo "$EXEC leaks!"
    result2=fail
fi
unset MEM_DEBUG
echo "test2 result = $result2
Done with test2

################################################################################
"

# The next tests simulate memory failures at lines where source code
# invokes a memory allocator.  These lines are stored in ll, which will
# be assigned to MEM_FAIL in the tests.
#
# This test will not simulate failure in err_msg.c because the driver
# application does not allocate memory for error messages.
ll=""
printf "Will simulate memory failures at:\n"
for f in $ASRC
do
    l=`egrep -n 'MALLOC|CALLOC|REALLOC' $f | sed "s!^\([0-9][0-9]*\):.*!${f}:\1!"`
    printf "%s\n" $l
    ll="$ll $l"
done
printf "\n"

echo "test3: simulate allocation failures in $EXEC"
result3=success
for l in $ll
do
    export MEM_FAIL=$l
    if ./$EXEC > /dev/null 2>&1
    then
	echo "$EXEC ran normally when it should have failed at $MEM_FAIL"
	result3=fail
    else
	echo "$EXEC failed as expected for failure at $MEM_FAIL"
    fi
    unset MEM_FAIL
done
echo "test3 result = $result3
All done with test3

################################################################################
"

echo "test4: repeat test4 with memory tracing."
export MEM_DEBUG=3
result4=success
for l in $ll
do
    export MEM_FAIL=$l
    if ./$EXEC 3>&1 > /dev/null 2>&1 | $CHKALLOC
    then
	echo "$EXEC exits without leaks when simulating failure at $MEM_FAIL"
    else
	status=$?
	if [ $status -eq 1 ]
	then
	    echo "$EXEC leaks when simulating failure at $MEM_FAIL"
	    result4=fail
	elif [ $status -eq 2 ]
	then
	    printf "%s%s\n" "chkalloc did not receive input from $EXEC" \
		    " when simulating failure at $MEM_FAIL"
	    result4=fail
	else
	    echo "chkalloc returned unknown value $status"
	    result4=fail
	fi
    fi
    unset MEM_FAIL
done
unset MEM_DEBUG
echo "test4 result=$result4
All done with test4

################################################################################
"

echo "Summary:
$0 test1 result = $result1
$0 test2 result = $result2
$0 test3 result = $result3
$0 test4 result = $result4
"

$RM $MSRC $EXEC

echo "$0 all done.

################################################################################
################################################################################
"

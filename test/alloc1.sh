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
# $Id: alloc1.sh,v 1.13 2008/12/08 05:52:56 gcarrie Exp $
#
########################################################################

echo "
alloc1.sh --

This script tests the allocators defined in src/alloc.c.  See
alloc (3) for information about these functions.

It creates a test application that allocates and frees memory.  It runs
the application while checking for memory leaks.  It also checks for
proper responses to errors and failures.

Usage suggestions:
./alloc1.sh 2>&1 | less
To save temporary files:
env RM=: ./alloc1.sh 2>&1 | less

Copyright (c) 2008 Gordon D. Carrie
Licensed under the Open Software License version 3.0

--------------------------------------------------------------------------------
"

# Set RM to : in environment to save temporary files.
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

echo "test1: normal run of alloc1"
result1=success
if ./alloc1
then
    echo "alloc1 ran."
else
    echo "alloc1 failed."
    result1=fail
fi
echo "test1 result = $result1
Done with test1

--------------------------------------------------------------------------------
"

echo "test2: running alloc1 with memory trace going to stderr."
result2=success
export MEM_DEBUG=2
./alloc1 2> test2.err
unset MEM_DEBUG
ptn='[0-9x]+ \([0-9]+\) (allocated|freed) (by realloc )?at alloc1\.c:[0-9]+'
if [ `egrep -c "$ptn" test2.err` -eq 8 ]
then
    echo "alloc1 error output was correct."
else
    echo "alloc1 error output was wrong."
    result2=fail
fi
$RM test2.err
echo "test2 result = $result2
Done with test2

--------------------------------------------------------------------------------
"

echo "test3: running alloc1 with memory trace going to a file."
result3=success
export MEM_DEBUG=test3.out
./alloc1
unset MEM_DEBUG
ptn='[0-9x]+ \([0-9]+\) (allocated|freed) (by realloc )?at alloc1\.c:[0-9]+'
if [ `egrep -c "$ptn" test3.out` -eq 8 ]
then
    echo "alloc1 output was correct."
else
    echo "alloc1 output was wrong."
    result3=fail
fi
$RM test3.out
echo "test3 result = $result3
Done with test3

--------------------------------------------------------------------------------
"

echo "test4: running alloc1 with memory trace going to chkalloc."
result4=success
export MEM_DEBUG=2
if ./alloc1 2>&1 | src/chkalloc
then
    echo "chkalloc reports that alloc1 did not leak memory."
else
    echo "alloc1 leaks."
    result4=fail
fi
unset MEM_DEBUG
echo "test4 result = $result4
Done with test4

--------------------------------------------------------------------------------
"

echo "test5: running alloc1, attempting to send memory trace to unwritable file."
result5=success
export MEM_DEBUG=alloc5.out
touch alloc5.out
chmod 444 alloc5.out
if ./alloc1 2>&1 \
	| grep -q "MEM_DEBUG set but unable to open diagnostic memory file:"
then
    echo "alloc1 error output was correct."
else
    echo "alloc1 error output was wrong."
    result5=fail
fi
chmod 644 alloc5.out
$RM alloc5.out
unset MEM_DEBUG
echo "test5 result = $result5
Done with test5

--------------------------------------------------------------------------------
"

echo "test6: simulate allocation failures"
result6=success
for n in `egrep -n 'MALLOC|CALLOC|REALLOC' alloc1.c | sed 's/:.*//'`
do
    export MEM_FAIL="alloc1.c:$n"
    if ./alloc1 2>&1 | egrep -q "Could not (re)?allocate x[123]"
    then
	echo "alloc1 error output was correct for simulated failure at $MEM_FAIL."
    else
	echo "alloc1 error output was wrong for simulated failure at $MEM_FAIL."
	result6=fail
    fi
    unset MEM_FAIL
done
echo "test6 result = $result6
Done with test6

--------------------------------------------------------------------------------
"

echo "Summary:
test1 result = $result1
test2 result = $result2
test3 result = $result3
test4 result = $result4
test5 result = $result5
test6 result = $result6
"

$RM alloc1.c alloc1
echo "$0 all done."

#!/bin/sh
#
#- alloc4f_2.sh --
#-	This test application tests the allocators defined in src/alloc4f.c
#-	It examines a process that attempts to allocate some impossibly large
#-	arrays.
#-
# Copyright (c) 2008 Gordon D. Carrie
# All rights reserved
#
# Please send feedback to dev0@trekix.net
#
# $Revision: 1.14 $ $Date: 2009/09/25 21:33:13 $
#
########################################################################

echo "
alloc4f_2.sh --

This test application tests the functions defined in src/alloc4f.c.
See alloc4f (3) for information on these functions.

It creates a test application named alloc4f_2 that attempts to make some
impossibly large arrays.

Usage suggestions:
./alloc4f_2.sh 2>&1 | less
To save temporary files:
env RM=: ./alloc4f_2.sh 2>&1 | less

Copyright (c) 2008 Gordon D. Carrie
All rights reserved

################################################################################
"

# Set RM to : to save intermediate files
RM=${RM:-'rm -f'}

CC="cc"
CFLAGS="-g -Wall -Wmissing-prototypes"
MSRC="alloc4f_2.c"
SRC="$MSRC src/alloc4f.c src/alloc.c src/err_msg.c"
EXEC="alloc4f_2"

# Here is the source code for the test application.
cat > $MSRC << END
#include <limits.h>
#include <stdio.h>
#include <err_msg.h>
#include <alloc.h>
#include <alloc4f.h>

int main(void)
{
    size_t lmax, kmax, jmax, imax;
    float ****x = NULL;

    lmax = ULONG_MAX - 1;
    kmax = 1000;
    jmax = 1000;
    imax = 1000;
    x = Calloc4F(lmax, kmax, jmax, imax);
    if ( !x ) {
	fprintf(stderr, "Could not allocate x:\n%s\n", Err_Get());
    }
    Free4F(x);

    lmax = (LONG_MAX / 3) * 2;
    kmax = 1000;
    jmax = 1000;
    imax = 1000;
    x = Calloc4F(lmax, kmax, jmax, imax);
    if ( !x ) {
	fprintf(stderr, "Could not allocate x:\n%s\n", Err_Get());
    }
    Free4F(x);

    lmax = 1000;
    kmax = ULONG_MAX - 1;
    jmax = 1000;
    imax = 1000;
    x = Calloc4F(lmax, kmax, jmax, imax);
    if ( !x ) {
	fprintf(stderr, "Could not allocate x:\n%s\n", Err_Get());
    }
    Free4F(x);

    lmax = 1000;
    kmax = (LONG_MAX / 3) * 2;
    jmax = 1000;
    imax = 1000;
    x = Calloc4F(lmax, kmax, jmax, imax);
    if ( !x ) {
	fprintf(stderr, "Could not allocate x:\n%s\n", Err_Get());
    }
    Free4F(x);

    lmax = 1000;
    kmax = 1000;
    jmax = ULONG_MAX - 1;
    imax = 1000;
    x = Calloc4F(lmax, kmax, jmax, imax);
    if ( !x ) {
	fprintf(stderr, "Could not allocate x:\n%s\n", Err_Get());
    }
    Free4F(x);

    lmax = 1000;
    kmax = 1000;
    jmax = (LONG_MAX / 3) * 2;
    imax = 1000;
    x = Calloc4F(lmax, kmax, jmax, imax);
    if ( !x ) {
	fprintf(stderr, "Could not allocate x:\n%s\n", Err_Get());
    }
    Free4F(x);

    lmax = 1000;
    kmax = 1000;
    jmax = 1000;
    imax = ULONG_MAX - 1;
    x = Calloc4F(lmax, kmax, jmax, imax);
    if ( !x ) {
	fprintf(stderr, "Could not allocate x:\n%s\n", Err_Get());
    }
    Free4F(x);

    lmax = 1000;
    kmax = 1000;
    jmax = 1000;
    imax = (LONG_MAX / 3) * 2;
    x = Calloc4F(lmax, kmax, jmax, imax);
    if ( !x ) {
	fprintf(stderr, "Could not allocate x:\n%s\n", Err_Get());
    }
    Free4F(x);

    return 0;
}
END

# This is standard output from the test application.
cat > ${EXEC}.out << END
Could not allocate x:
Array dimensions must be positive.

Could not allocate x:
Dimensions too big for pointer arithmetic.

Could not allocate x:
Array dimensions must be positive.

Could not allocate x:
Dimensions too big for pointer arithmetic.

Could not allocate x:
Array dimensions must be positive.

Could not allocate x:
Dimensions too big for pointer arithmetic.

Could not allocate x:
Array dimensions must be positive.

Could not allocate x:
Dimensions too big for pointer arithmetic.

END

# Build the test application
if ! $CC $CFLAGS -Isrc -o $EXEC $SRC
then
    echo "Build failed."
    exit 1
fi

# Run the tests
echo "test1: attempting to run $EXEC."
if ./$EXEC 2>&1 | diff ${EXEC}.out -
then
    echo "alloc2f_1 produced correct output."
    result1=success
else
    echo "alloc2f_1 produced bad output!"
    result1=fail
fi
$RM ${EXEC}.out
echo "Summary:
$0 test1 result = $result1
Done with test1

################################################################################
"

$RM $EXEC $MSRC

echo "$0 all done.

################################################################################
################################################################################
"

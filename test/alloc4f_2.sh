#!/bin/sh
#
#- alloc4f_2.sh --
#-	This script tests the allocators defined in src/alloc4f.c
#-	It attempts to allocate some impossibly large arrays.
#-
# Copyright (c) 2008 Gordon D. Carrie
#
# Licensed under the Open Software License version 3.0
#
# Please send feedback to dev0@trekix.net
#
# $Id: alloc4f_2.sh,v 1.2 2008/12/12 21:16:53 gcarrie Exp $
#
########################################################################

echo "
alloc4f_2.sh --

This script tests the functions defined in src/alloc4f.c.
See alloc4f (3) for information on these functions.

It creates a test application named alloc4f_2 that attempts to make some
impossibly large arrays.

Usage suggestions:
./alloc4f_2.sh 2>&1 | less
To save temporary files:
env RM=: ./alloc4f_2.sh 2>&1 | less

Copyright (c) 2008 Gordon D. Carrie
Licensed under the Open Software License version 3.0

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
cat > alloc4f_2.c << END
#include <limits.h>
#include <stdio.h>
#include <err_msg.h>
#include <alloc4f.h>

int main(void)
{
    size_t lmax, kmax, jmax, imax;
    float ****x = NULL;

    lmax = ULONG_MAX - 1;
    kmax = 1000;
    jmax = 1000;
    imax = 1000;
    x = calloc4f(lmax, kmax, jmax, imax);
    if ( !x ) {
	fprintf(stderr, "Could not allocate x:\n%s\n", err_get());
    }
    free4f(x);

    lmax = (LONG_MAX / 3) * 2;
    kmax = 1000;
    jmax = 1000;
    imax = 1000;
    x = calloc4f(lmax, kmax, jmax, imax);
    if ( !x ) {
	fprintf(stderr, "Could not allocate x:\n%s\n", err_get());
    }
    free4f(x);

    lmax = 1000;
    kmax = ULONG_MAX - 1;
    jmax = 1000;
    imax = 1000;
    x = calloc4f(lmax, kmax, jmax, imax);
    if ( !x ) {
	fprintf(stderr, "Could not allocate x:\n%s\n", err_get());
    }
    free4f(x);

    lmax = 1000;
    kmax = (LONG_MAX / 3) * 2;
    jmax = 1000;
    imax = 1000;
    x = calloc4f(lmax, kmax, jmax, imax);
    if ( !x ) {
	fprintf(stderr, "Could not allocate x:\n%s\n", err_get());
    }
    free4f(x);

    lmax = 1000;
    kmax = 1000;
    jmax = ULONG_MAX - 1;
    imax = 1000;
    x = calloc4f(lmax, kmax, jmax, imax);
    if ( !x ) {
	fprintf(stderr, "Could not allocate x:\n%s\n", err_get());
    }
    free4f(x);

    lmax = 1000;
    kmax = 1000;
    jmax = (LONG_MAX / 3) * 2;
    imax = 1000;
    x = calloc4f(lmax, kmax, jmax, imax);
    if ( !x ) {
	fprintf(stderr, "Could not allocate x:\n%s\n", err_get());
    }
    free4f(x);

    lmax = 1000;
    kmax = 1000;
    jmax = 1000;
    imax = ULONG_MAX - 1;
    x = calloc4f(lmax, kmax, jmax, imax);
    if ( !x ) {
	fprintf(stderr, "Could not allocate x:\n%s\n", err_get());
    }
    free4f(x);

    lmax = 1000;
    kmax = 1000;
    jmax = 1000;
    imax = (LONG_MAX / 3) * 2;
    x = calloc4f(lmax, kmax, jmax, imax);
    if ( !x ) {
	fprintf(stderr, "Could not allocate x:\n%s\n", err_get());
    }
    free4f(x);

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
echo "test1 result = $result1
Done with test1

################################################################################
"

$RM $EXEC $MSRC

echo "$0 all done.

################################################################################
################################################################################
"

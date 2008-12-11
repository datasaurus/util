#!/bin/sh
#
#- alloc2f_2.sh --
#-	This script tests the allocators defined in src/alloc2f.c
#-	It attempts to allocate some impossibly large arrays.
#-
# Copyright (c) 2008 Gordon D. Carrie
#
# Licensed under the Open Software License version 3.0
#
# Please send feedback to dev0@trekix.net
#
# $Id: alloc2f_2.sh,v 1.5 2008/12/05 21:17:40 gcarrie Exp $
#
########################################################################

echo "
alloc2f_2.sh --

This script tests the functions defined in src/alloc2f.c.
See alloc2f (3) for information on these functions.

It creates a test application named alloc2f_2 that attempts to make some
impossibly large arrays.

Usage suggestions:
./alloc2f_2.sh 2>&1 | less
To save temporary files:
env RM=: ./alloc2f_2.sh 2>&1 | less

Copyright (c) 2008 Gordon D. Carrie
Licensed under the Open Software License version 3.0

--------------------------------------------------------------------------------
"

# Set RM to : to save intermediate files
RM=${RM:-'rm -f'}

CC="cc"
CFLAGS="-g -Wall -Wmissing-prototypes"

# Here is the source code for the test application.
cat > alloc2f_2.c << END
#include <limits.h>
#include <stdio.h>
#include <err_msg.h>
#include <alloc2f.h>

int main(void)
{
    size_t j_max, i_max;
    float **x = NULL;

    j_max = ULONG_MAX - 1;
    i_max = 1000;
    x = calloc2f(j_max, i_max);
    if ( !x ) {
	fprintf(stderr, "Could not allocate x:\n%s\n", err_get());
    }
    free2f(x);

    j_max = (LONG_MAX / 3) * 2;
    i_max = 1000;
    x = calloc2f(j_max, i_max);
    if ( !x ) {
	fprintf(stderr, "Could not allocate x:\n%s\n", err_get());
    }
    free2f(x);

    j_max = 1000;
    i_max = ULONG_MAX - 1;
    x = calloc2f(j_max, i_max);
    if ( !x ) {
	fprintf(stderr, "Could not allocate x:\n%s\n", err_get());
    }
    free2f(x);

    j_max = 1000;
    i_max = (LONG_MAX / 3) * 2;
    x = calloc2f(j_max, i_max);
    if ( !x ) {
	fprintf(stderr, "Could not allocate x:\n%s\n", err_get());
    }
    free2f(x);

    return 0;
}
END

SRC="alloc2f_2.c src/alloc2f.c src/alloc.c src/err_msg.c"
if ! $CC $CFLAGS -Isrc -o alloc2f_2 $SRC
then
    echo "Build failed."
    exit 1
fi


echo "test1: attempting to run alloc2f_2."
cat > correct1.out << END
Could not allocate x:
Array dimensions must be positive.

Could not allocate x:
Dimensions too big for pointer arithmetic.

Could not allocate x:
Array dimensions must be positive.

Could not allocate x:
Dimensions too big for pointer arithmetic.

END
if ./alloc2f_2 2>&1 | diff correct1.out -
then
    echo "alloc2f_1 produced correct output."
    result1=success
else
    echo "alloc2f_1 produced bad output!"
    result1=fail
fi
$RM correct1.out
echo "test1 result = $result1
Done with test1

--------------------------------------------------------------------------------
"

$RM alloc2f_2 alloc2f_2.c

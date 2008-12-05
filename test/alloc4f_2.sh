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
# $Id: $
#
########################################################################

# Set RM to : to save intermediate files
RM=${RM:-'rm -f'}

CC="cc"
CFLAGS="-g -Wall -Wmissing-prototypes"

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

echo "building alloc4f_2"
SRC="alloc4f_2.c src/alloc4f.c src/alloc.c src/err_msg.c"
if $CC $CFLAGS -Isrc -o alloc4f_2 $SRC
then
    echo "success"
else
    echo "Build failed."
    exit 1
fi
echo ""

echo "running alloc4f_2."
echo It should complain about excessively large or non-positive dimensions.
echo ""
echo Starting test
echo "------------------------------------------------------------------------"
alloc4f_2
echo "------------------------------------------------------------------------"
echo Done with test

$RM alloc4f_2 alloc4f_2.c

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
# $Id: alloc2f_2.sh,v 1.4 2008/12/02 17:19:39 gcarrie Exp $
#
########################################################################

# Set RM to : to save intermediate files
RM=${RM:-'rm -f'}

# Here is the source code for the test application.

cat > alloc2f_2.c << END
#include <limits.h>
#include <stdio.h>
#include <alloc2f.h>

int main(void)
{
    size_t j_max, i_max;
    int j, i;
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

echo test1: building and running alloc2f_2.
echo It should complain about excessively large or non-positive dimensions.
echo ""
cc -Isrc -o alloc2f_2 alloc2f_2.c src/alloc2f.c src/alloc.c src/err_msg.c
echo Starting test1
alloc2f_2
echo Done with test1
echo ""

$RM alloc2f_2 alloc2f_2.c

#!/bin/sh
#
# This script tests the allocators defined in src/allocf.c
#
# Copyright (c) 2008 Gordon D. Carrie
#
# Licensed under the Open Software License version 3.0
#
# Please send feedback to user0@tkgeomap.org
#
# $Id: allocf2.sh,v 1.2 2008/11/17 04:56:22 gcarrie Exp $
#
########################################################################

# This is the remove command.  Change this to : to retain intermediate results.

RM='rm -f'

# Here is the source code for the test application.
# It attempts to allocate some impossibly large arrays.

cat > allocf2.c << END
#include <limits.h>
#include <stdio.h>
#include <allocf.h>

int main(void)
{
    size_t j_max, i_max;
    int j, i;
    float **x = NULL;

    j_max = ULONG_MAX - 1;
    i_max = 1000;
    x = mallocf2(j_max, i_max);
    if ( !x ) {
	fprintf(stderr, "Could not allocate x:\n%s\n", err_get());
    }
    freef2(x);
    return 0;
}
END

echo test1: building and running allocf2.
echo It should complain about non-positive dimensions.
echo ""
cc -Isrc -o allocf2 allocf2.c src/allocf.c src/alloc.c src/err_msg.c
echo Starting test1
allocf2
echo Done with test1
echo ""

$RM allocf2 allocf2.c

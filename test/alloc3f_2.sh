#!/bin/sh
#
#- alloc3f_2.sh --
#-	This test application tests the allocators defined in src/alloc3f.c
#-	It examines a process that attempts to allocate some impossibly large
#-	arrays.
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
# $Revision: 1.16 $ $Date: 2014/01/24 22:34:25 $
#
########################################################################

echo "
alloc3f_2.sh --

This test application tests the functions defined in src/alloc3f.c.
See alloc3f (3) for information on these functions.

It creates a test application named alloc3f_2 that attempts to make some
impossibly large arrays.

Usage suggestions:
./alloc3f_2.sh 2>&1 | less
To save temporary files:
env RM=: ./alloc3f_2.sh 2>&1 | less

Copyright (c) 2011 Gordon D. Carrie
All rights reserved

################################################################################
"

# Set RM to : to save intermediate files
RM=${RM:-'rm -f'}

CC="cc -std=c99"
CFLAGS="-g -Wall -Wmissing-prototypes"
MSRC="alloc3f_2.c"
SRC="$MSRC src/alloc3f.c src/alloc.c src/err_msg.c"
EXEC="alloc3f_2"

# Here is the source code for the test application.

cat > $MSRC << END
#include <limits.h>
#include <stdio.h>
#include <err_msg.h>
#include <alloc.h>
#include <alloc3f.h>

int main(void)
{
    size_t kmax, jmax, imax;
    float ***x = NULL;

    kmax = ULONG_MAX - 1;
    jmax = 1000;
    imax = 1000;
    x = Calloc3F(kmax, jmax, imax);
    if ( !x ) {
	fprintf(stderr, "Could not allocate x:\n%s\n", Err_Get());
    }
    Free3F(x);

    kmax = (LONG_MAX / 3) * 2;
    jmax = 1000;
    imax = 1000;
    x = Calloc3F(kmax, jmax, imax);
    if ( !x ) {
	fprintf(stderr, "Could not allocate x:\n%s\n", Err_Get());
    }
    Free3F(x);

    kmax = 1000;
    jmax = ULONG_MAX - 1;
    imax = 1000;
    x = Calloc3F(kmax, jmax, imax);
    if ( !x ) {
	fprintf(stderr, "Could not allocate x:\n%s\n", Err_Get());
    }
    Free3F(x);

    kmax = 1000;
    jmax = (LONG_MAX / 3) * 2;
    imax = 1000;
    x = Calloc3F(kmax, jmax, imax);
    if ( !x ) {
	fprintf(stderr, "Could not allocate x:\n%s\n", Err_Get());
    }
    Free3F(x);

    kmax = 1000;
    jmax = 1000;
    imax = ULONG_MAX - 1;
    x = Calloc3F(kmax, jmax, imax);
    if ( !x ) {
	fprintf(stderr, "Could not allocate x:\n%s\n", Err_Get());
    }
    Free3F(x);

    kmax = 1000;
    jmax = 1000;
    imax = (LONG_MAX / 3) * 2;
    x = Calloc3F(kmax, jmax, imax);
    if ( !x ) {
	fprintf(stderr, "Could not allocate x:\n%s\n", Err_Get());
    }
    Free3F(x);

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

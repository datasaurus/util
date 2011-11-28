#!/bin/sh
#
#- alloc2.sh --
#-	This test application tests the allocators defined in src/alloc.c
#-	and application src/chkalloc.  It examines a process that intentionally
#-	leaks memory.
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
#
# Please send feedback to dev0@trekix.net
#
# $Revision: 1.24 $ $Date: 2009/09/25 21:33:13 $
#
########################################################################

echo "
alloc2.sh --

This test application tests the allocators defined in src/alloc.c and
src/chkalloc.  See alloc (3) and chkalloc (1).

It creates a test program that intentionally fails to free memory that it
allocates.

Usage suggestions:
./alloc1.sh 2>&1 | less
To save temporary files:
env RM=: ./alloc1.sh 2>&1 | less

Copyright (c) 2008 Gordon D. Carrie
All rights reserved

################################################################################
"

CHKALLOC=src/chkalloc
if ! test -x $CHKALLOC
then
    echo "No executable named $CHKALLOC"
    exit 1
fi

# Set RM to : in environment to save temporary files.
RM=${RM:-'rm -f'}

CC="cc"
CFLAGS="-g -Wall -Wmissing-prototypes"

# Here is the source code for the driver application.
cat > alloc2.c << END
#include <alloc.h>

int main(void)
{
    size_t i;
    float *x1, *x2, *x3;

    i = 1000;
    x1 = CALLOC(i, sizeof(float));
    FREE(x1);

    x2 = CALLOC(i, sizeof(float));
    i = 2000;
    x3 = REALLOC(x2, i * sizeof(float));

    return 0;
}
END

if ! $CC $CFLAGS -Isrc -o alloc2 src/alloc.c alloc2.c
then
    echo "Could not compile the test application"
    exit 1
fi

# Run the tests

echo "test1: normal run of alloc2."
if ./alloc2
then
    echo "alloc2 ran."
    result1=success
else
    echo "alloc2 failed."
    result1=fail
fi
echo "test1 result = $result1
Done with test1

################################################################################
"

echo "test2: running alloc2 with memory trace."
export MEM_DEBUG=2
if ./alloc2 2>&1 | $CHKALLOC
then
    echo "chkalloc failed to find the leak"
    result2=fail
else
    status=$?
    if [ $status -eq 1 ]
    then
	echo "chkalloc found leak (as it should have)"
	result2=success
    elif [ $status -eq 2 ]
    then
	echo "chkalloc did not receive input"
	result2=fail
    else
	echo "chkalloc returned unknown value $status"
	result2=fail
    fi
fi
unset MEM_DEBUG
echo "test2 result = $result2
Done with test2

################################################################################
"

echo "Summary:
$0 test1 result = $result1
$0 test2 result = $result2
"

$RM alloc2.c alloc2

echo "$0 all done.

################################################################################
################################################################################
"

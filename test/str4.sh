#!/bin/sh
#
#- str4.sh --
#-	This script tests the Str_Append function in the str interface.
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
# $Revision: 1.6 $ $Date: 2014/01/24 22:34:25 $
#
########################################################################

# This is the remove command.  Change this to : to retain intermediate results.

RM=${RM:-'rm -f'}

# Test application
cat > str4.c << END
#include <stdio.h>
#include <string.h>
#include "src/alloc.h"
#include "src/str.h"

int main(void)
{
    char *s1 = "This is a test string.\nIt has stuff in it.\n";
    char *s2 = "And this is the continuation.\n";
    char *s = NULL;
    size_t l = 0, lx = 0;

    if ( !(s = Str_Append(s, &l, &lx, s1, strlen(s1))) ) {
	fprintf(stderr, "Could not initialize s\n");
	exit(EXIT_FAILURE);
    }
    if ( !(s = Str_Append(s, &l, &lx, s2, strlen(s2))) ) {
	fprintf(stderr, "Could not append to s\n");
	exit(EXIT_FAILURE);
    }
    printf("%s\n", s);
    FREE(s);

    return 0;
}
END

# This should be the output
cat > correct << END
This is a test string.
It has stuff in it.
And this is the continuation.

END

# Build the test application
CFLAGS="-std=c99 -g -Wall -Wmissing-prototypes"
if ! cc ${CFLAGS} -o str4 str4.c src/str.c src/err_msg.c src/alloc.c
then
    echo 'Could not build str4 from str4.c'
    $RM str4.c str
    exit 1
fi

echo "########################################################################"

# Normal run, checking for leaks with chkalloc.  See alloc (3) and chkalloc (3).
echo "
test1
normal run
"
export MEM_DEBUG=2
if ! ./str4 > attempt 2> memtrace
then
    echo 'Test application failed to run.'
    exit 1
fi
if diff correct attempt
then
    echo "String append driver produced correct output."
else
    echo "String driver failed!"
    exit 1
fi
echo "test1 done
"

echo 'Checking memory trace (will not say anything if no leaks)'
src/chkalloc < memtrace
echo 'Memory check done'

# The next tests simulate memory failures at lines where source code for Str_Words
# invokes a memory allocator.  These lines are stored in ll, which will
# be assigned to MEM_FAIL in the tests.

CHKALLOC=src/chkalloc
ll=`awk '{printf "%d %s\n", ++i, $0}' ../src/str.c	\
   | awk '/char *\* *Str_Append/, /^[0-9]+ }/'			\
   | awk '/ALLOC/ {printf "src/str.c:%d\n", $1}'`

echo "########################################################################"

# Check for exit with failure status when an allocator fails.
echo "
test2
Simulating memory failures."
result2=success
for l in $ll
do
    export MEM_FAIL=$l
    if ./str4 > /dev/null 2>&1
    then
	echo "FAIL: String driver ran normally instead of failing at $MEM_FAIL"
	result2=fail
    else
	echo "String driver failed as expected for failure at $MEM_FAIL"
    fi
    unset MEM_FAIL
done
echo "test2 result = $result2
All done with test2
"

echo "########################################################################"

# Check for memory leaks at when an allocator fails.
echo "
test3
Repeat test2 with memory tracing."
export MEM_DEBUG=3
result3=success
for l in $ll
do
    export MEM_FAIL=$l
    echo "Simulating memory failure at $l."
    if ./str4 3>&1 > /dev/null 2>&1 | $CHKALLOC
    then
	echo "str4 exits without leaks when simulating failure at $MEM_FAIL"
    else
	status=$?
	if [ $status -eq 1 ]
	then
	    echo "FAIL: str4 leaks when simulating failure at $MEM_FAIL"
	    result3=FAIL
	elif [ $status -eq 2 ]
	then
	    printf "%s%s\n" "FAIL: chkalloc did not receive input from str4" \
		    " when simulating failure at $MEM_FAIL"
	    result3=FAIL
	else
	    echo "FAIL: chkalloc returned unknown value $status"
	    result3=FAIL
	fi
    fi
    unset MEM_FAIL
done
unset MEM_DEBUG
echo "test3 result=$result3
All done with test3
"

echo "########################################################################"

$RM str4.c str4 attempt correct memtrace
echo 'Done with str4 test'

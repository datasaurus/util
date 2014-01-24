#!/bin/sh
#
#- str5.sh --
#	This script tests the Str_GetLn function in the str interface.
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
# $Revision: 1.4 $ $Date: 2011/11/28 16:11:23 $
#
########################################################################

# This is the remove command.  Change this to : to retain intermediate results.

RM=${RM:-'rm -f'}

# Test application
cat > str5.c << END
#include <stdio.h>
#include <string.h>
#include "src/alloc.h"
#include "src/err_msg.h"
#include "src/str.h"

int main(void)
{
    char *s;
    int l_max;
    int status;

    s = NULL;
    l_max = 0;
    while ( (status = Str_GetLn(stdin, '\n', &s, &l_max)) == 1 ) {
	printf("%s\n", s);
    }
    FREE(s);
    if ( status == 0 ) {
	fprintf(stderr, "Str_GetLn failed.\n%s\n", Err_Get());
	exit(EXIT_FAILURE);
    }
    if ( status != EOF  ) {
	fprintf(stderr, "Str_GetLn terminated before end of input.\n");
	exit(EXIT_FAILURE);
    }

    return 0;
}
END

# Build the test application
CFLAGS="-std=c99 -g -Wall -Wmissing-prototypes"
if ! cc ${CFLAGS} -o str5 str5.c src/str.c src/err_msg.c src/alloc.c
then
    echo "Could not build str5 from str5.c"
    $RM str5.c str
    exit 1
fi

echo "########################################################################"

# Test 1
echo "$0: test 1"
cat > correct1 << END
line 1
line 2
END
export MEM_DEBUG=2
if ! ./str5 < correct1 > attempt 2> memtrace
then
    echo "Test application failed to run."
    exit 1
fi
if diff correct1 attempt
then
    echo "Str_GetLn driver produced correct1 output."
else
    echo "String driver failed!"
    exit 1
fi
echo "Checking memory trace (will not say anything if no leaks)"
src/chkalloc < memtrace
echo "Memory check done"
echo "$0 done with test 1"
echo ""
$RM attempt memtrace

echo "########################################################################"

# Test 2
echo "$0: test 2"
cat > correct2 << END
line 1

END
export MEM_DEBUG=2
if ! ./str5 < correct2 > attempt 2> memtrace
then
    echo "Test application failed to run."
    exit 1
fi
if diff correct2 attempt
then
    echo "Str_GetLn driver produced correct2 output."
else
    echo "String driver failed!"
    exit 1
fi
echo "Checking memory trace (will not say anything if no leaks)"
src/chkalloc < memtrace
echo "Memory check done"
echo "$0 done with test 2"
echo ""
$RM attempt memtrace

echo "########################################################################"

# Test 3
echo "$0: test 3"
cat /dev/null > correct3
export MEM_DEBUG=2
if ! ./str5 < correct3 > attempt 2> memtrace
then
    echo "Test application failed to run."
    exit 1
fi
if diff correct3 attempt
then
    echo "Str_GetLn driver produced correct3 output."
else
    echo "String driver failed!"
    exit 1
fi
echo "Checking memory trace (will not say anything if no leaks)"
src/chkalloc < memtrace
echo "Memory check done"
echo "$0 done with test 3"
echo ""
$RM attempt memtrace

# The next tests simulate memory failures at lines where source code for Str_Words
# invokes a memory allocator.  These lines are stored in ll, which will
# be assigned to MEM_FAIL in the tests.

CHKALLOC=src/chkalloc
ll=`( awk '{printf "%d %s\n", ++i, $0}' ../src/str.c	\
	| awk '/char *\* *Str_Append/, /^[0-9]+ }/';
	awk '{printf "%d %s\n", ++i, $0}' ../src/str.c	\
	| awk '/int *Str_GetLn/, /^[0-9]+ }/' )		\
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
    if ./str5 < correct1 > /dev/null 2>&1
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
    if ./str5 < correct1 3>&1 > /dev/null 2>&1 | $CHKALLOC
    then
	echo "str5 exits without leaks when simulating failure at $MEM_FAIL"
    else
	status=$?
	if [ $status -eq 1 ]
	then
	    echo "FAIL: str5 leaks when simulating failure at $MEM_FAIL"
	    result3=FAIL
	elif [ $status -eq 2 ]
	then
	    printf "%s%s\n" "FAIL: chkalloc did not receive input from str5" \
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

$RM str5.c str5 correct* attempt memtrace
echo "Done with str5 test"

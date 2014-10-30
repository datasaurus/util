#!/bin/sh
#
#- str3.sh --
#	This script tests the Str_Words function in the str interface.
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
# $Revision: 1.11 $ $Date: 2014/01/24 22:34:25 $
#
########################################################################

# This is the remove command.  Change this to : to retain intermediate results.

RM=${RM:-'rm -f'}
CHKALLOC=src/chkalloc

# Test application
cat > str3.c << END
#include <string.h>
#include <stdio.h>
#include "src/alloc.h"
#include "src/err_msg.h"
#include "src/str.h"

int main(void)
{
    char s[256], **words;
    int n, n_words;
    char *s1[] = {
	"Now is the time ...",
	"Now is the time ... ",
	" Now is the time ...",
	" Now is the time ... ",
	"I have a \"lovely bunch\" of coconuts.",
	"I have a \"lovely bu\"nch of coconuts.",
	"I have a lov\"ely bunch\" of coconuts.",
	"I have \"\" coconuts.",
	" ",
	"\t",
	"",
	NULL
    };
    char **p;

    n_words = 1;
    if ( !(words = CALLOC((n_words + 1), sizeof(char *))) ) {
	fprintf(stderr, "Could not initialize words array.\n");
	exit(1);
    }
    for (p = s1; *p; p++) {
	strcpy(s, *p);
	if ( !(words = Str_Words(s, words, &n_words)) ) {
	    printf("Test failed for string %ld.\n%s\n", p - s1 + 1, Err_Get());
	    exit(EXIT_FAILURE);
	} else {
	    printf("test %ld: \"%s\" found %d words:\n",
		    p - s1 + 1, s1[p - s1], n_words);
	    for (n = 0; n < n_words; n++) {
		printf("|%s|\n", words[n]);
	    }
	}
	printf("\n");
	n_words = 0;
    }
    FREE(words);

    return 0;
}
END

# This should be the output
cat > correct << END
test 1: "Now is the time ..." found 5 words:
|Now|
|is|
|the|
|time|
|...|

test 2: "Now is the time ... " found 5 words:
|Now|
|is|
|the|
|time|
|...|

test 3: " Now is the time ..." found 5 words:
|Now|
|is|
|the|
|time|
|...|

test 4: " Now is the time ... " found 5 words:
|Now|
|is|
|the|
|time|
|...|

test 5: "I have a "lovely bunch" of coconuts." found 6 words:
|I|
|have|
|a|
|lovely bunch|
|of|
|coconuts.|

test 6: "I have a "lovely bu"nch of coconuts." found 6 words:
|I|
|have|
|a|
|lovely bunch|
|of|
|coconuts.|

test 7: "I have a lov"ely bunch" of coconuts." found 6 words:
|I|
|have|
|a|
|lovely bunch|
|of|
|coconuts.|

test 8: "I have "" coconuts." found 4 words:
|I|
|have|
||
|coconuts.|

test 9: " " found 0 words:

test 10: "	" found 0 words:

test 11: "" found 0 words:

END

# Build the test application
CFLAGS="-std=c99 -g -Wall -Wmissing-prototypes"
if ! cc ${CFLAGS} -o str3 str3.c src/str.c src/err_msg.c src/alloc.c
then
    echo 'Could not build str3 from str3.c'
    $RM str3.c str
    exit 1
fi

echo "########################################################################"

# Normal run, checking for leaks with chkalloc.  See alloc (3) and chkalloc (3).
echo "
test1
normal run"
export MEM_DEBUG=2
if ! ./str3 > attempt 2> memtrace
then
    echo 'Test application FAILED to run.'
    exit 1
fi
if diff correct attempt
then
    echo "String driver produced correct output"
else
    echo "String driver FAILED!"
    exit 1
fi

echo 'Checking memory trace (will not say anything if no leaks)'
src/chkalloc < memtrace
echo 'Memory check done'
echo "Done with test1
"

# The next tests simulate memory failures at lines where source code for Str_Words
# invokes a memory allocator.  These lines are stored in ll, which will
# be assigned to MEM_FAIL in the tests.

ll=`awk '{printf "%d %s\n", ++i, $0}' ../src/str.c	\
   | grep -v '/\* new \*/'				\
   | awk '/Str_Words/, /^[0-9]+ }/'			\
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
    if ./str3 > /dev/null 2>&1
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
    if ./str3 3>&1 > /dev/null 2>&1 | $CHKALLOC
    then
	echo "str3 exits without leaks when simulating failure at $MEM_FAIL"
    else
	status=$?
	if [ $status -eq 1 ]
	then
	    echo "FAIL: str3 leaks when simulating failure at $MEM_FAIL"
	    result3=FAIL
	elif [ $status -eq 2 ]
	then
	    printf "%s%s\n" "FAIL: chkalloc did not receive input from str3" \
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

$RM str3.c str3 attempt correct memtrace
echo "
Done with str3 test
"

#!/bin/sh
#
#- str3.sh --
#	This script tests the Str_Words function in the str interface.
#-
# Copyright (c) 2009 Gordon D. Carrie
# All rights reserved
#
# Please send feedback to dev0@trekix.net
#
# $Revision: 1.4 $ $Date: 2009/12/31 02:46:13 $
#
########################################################################

# This is the remove command.  Change this to : to retain intermediate results.

RM=${RM:-'rm -f'}

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

    words = NULL;
    for (p = s1; *p; p++) {
	strcpy(s, *p);
	if ( !(words = Str_Words(s, words, &n_words)) ) {
	    printf("test %ld failed.\n%s\n", p - s1 + 1, Err_Get());
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
CFLAGS="-g -Wall -Wmissing-prototypes"
if ! cc ${CFLAGS} -o str3 str3.c src/str.c src/err_msg.c src/alloc.c
then
    echo 'Could not build str3 from str3.c'
    $RM str3.c str
    exit 1
fi

# Normal run, checking for leaks with chkalloc.  See alloc (3) and chkalloc (3).
export MEM_DEBUG=2
if ! ./str3 > attempt 2> memtrace
then
    echo 'Test application failed to run.'
    exit 1
fi
if diff correct attempt
then
    echo "string driver produced correct output"
else
    echo "string driver failed!"
    exit 1
fi
echo ""

echo 'Checking memory trace (will not say anything if no leaks)'
src/chkalloc < memtrace
echo 'Memory check done'

$RM str3.c str3 attempt correct memtrace
echo 'Done with str3 test'

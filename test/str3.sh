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
# $Revision: 1.3 $ $Date: 2009/12/23 16:30:44 $
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
	" Now is the time ...",
	"I have a \"lovely bunch\" of coconuts.",
	"I have a \"lovely bunch\"ling of coconuts.",
	"I have a \"lovely bunch\"ling of coconuts.",
	"I have \"\" coconuts.",
	"", NULL
    };
    char **p;

    for (p = s1; *p; p++) {
	strcpy(s, *p);
	if ( !(words = Str_Words(s, NULL, &n_words)) ) {
	    printf("test %ld failed.\n%s\n", p - s1 + 1, Err_Get());
	} else {
	    printf("test %ld:\n\"%s\"\nFound %d words:\n",
		    p - s1 + 1, s1[p - s1], n_words);
	    for (n = 0; n < n_words; n++) {
		printf("%s\n", words[n]);
	    }
	}
	printf("\n");
	FREE(words);
    }

    return 0;
}
END

CFLAGS="-g -Wall -Wmissing-prototypes"
if ! cc ${CFLAGS} -o str3 str3.c src/str.c src/err_msg.c src/alloc.c
then
    echo 'Could not build str3 from str3.c'
    $RM str3.c str
    exit 1
fi
if ./str3
then
    echo 'Test application succeeded.'
else
    echo 'Test application FAILED.'
fi

$RM str3.c str3
echo 'Done with str3 test'

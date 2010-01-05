#!/bin/sh
#
#- str1.sh --
#	This script tests the Str_Esc function in the str interface.
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
cat > str1.c << END
#include <string.h>
#include <stdio.h>
#include "src/str.h"

int main(void)
{
    char s[22];
    int status;

    strcpy(s, "\\\\a\\\\b\\\\f\\\\n\\\\r\\\\t\\\\v\\\\'\\\\\\\\\\\\04");
    printf("Before escape s has %lu chars.\n", strlen(s));
    Str_Esc(s);
    printf("After escape s has %lu chars.\n", strlen(s));
    status = EXIT_SUCCESS;
    if (s[0] != '\a') {
	printf("\a did not escape.\n");
	status = EXIT_FAILURE;;
    }
    if (s[1] != '\b') {
	printf("\b did not escape.\n");
	status = EXIT_FAILURE;;
    }
    if (s[2] != '\f') {
	printf("\f did not escape.\n");
	status = EXIT_FAILURE;;
    }
    if (s[3] != '\n') {
	printf("\n did not escape.\n");
	status = EXIT_FAILURE;;
    }
    if (s[4] != '\r') {
	printf("\r did not escape.\n");
	status = EXIT_FAILURE;;
    }
    if (s[5] != '\t') {
	printf("\t did not escape.\n");
	status = EXIT_FAILURE;;
    }
    if (s[6] != '\v') {
	printf("\v did not escape.\n");
	status = EXIT_FAILURE;;
    }
    if (s[7] != '\'') {
	printf("\' did not escape.\n");
	status = EXIT_FAILURE;;
    }
    if (s[8] != '\\\\') {
	printf("\\\\ did not escape.\n");
	status = EXIT_FAILURE;;
    }
    if (s[9] != 4) {
	printf("\\04 did not escape.\n");
	status = EXIT_FAILURE;;
    }
    return status;
}
END

CFLAGS="-g -Wall -Wmissing-prototypes"
if ! cc ${CFLAGS} -o str1 str1.c src/str.c src/err_msg.c src/alloc.c
then
    echo 'Could not build str1 from str1.c'
    $RM str1.c str
    exit 1
fi
if ./str1
then
    echo 'Test application succeeded.'
else
    echo 'Test application FAILED.'
fi

$RM str1.c str1
echo 'Done with str1 test'

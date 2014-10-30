#!/bin/sh
#
#- str1.sh --
#	This script tests the Str_Esc function in the str interface.
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
# $Revision: 1.6 $ $Date: 2014/01/24 22:34:25 $
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

CFLAGS="-std=c99 -g -Wall -Wmissing-prototypes"
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

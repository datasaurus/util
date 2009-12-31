#!/bin/sh
#
#- str4.sh --
#	This script tests the Str_Append function in the str interface.
#-
# Copyright (c) 2009 Gordon D. Carrie
# All rights reserved
#
# Please send feedback to dev0@trekix.net
#
# $Revision: 1.3 $ $Date: 2009/12/31 00:46:35 $
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
CFLAGS="-g -Wall -Wmissing-prototypes"
if ! cc ${CFLAGS} -o str4 str4.c src/str.c src/err_msg.c src/alloc.c
then
    echo 'Could not build str4 from str4.c'
    $RM str4.c str
    exit 1
fi

# Normal run, checking for leaks with chkalloc.  See alloc (3) and chkalloc (3).
export MEM_DEBUG=2
if ! ./str4 > attempt 2> memtrace
then
    echo 'Test application failed to run.'
    exit 1
fi
if diff correct attempt
then
    echo "String append driver produced correct output."
    $RM attempt hash
else
    echo "String driver failed!"
    exit 1
fi
echo ""

echo 'Checking memory trace (will not say anything if no leaks)'
src/chkalloc < memtrace
echo 'Memory check done'

$RM str4.c str4 attempt correct memtrace
echo 'Done with str3 test'

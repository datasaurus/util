#!/bin/sh
#
#- str5.sh --
#	This script tests the Str_Append function in the str interface.
#-
# Copyright (c) 2009 Gordon D. Carrie
# All rights reserved
#
# Please send feedback to dev0@trekix.net
#
# $Revision: 1.1 $ $Date: 2009/12/31 02:22:04 $
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
    char *s = NULL;
    int l_max = 0;

    while ( Str_GetLn(stdin, '\n', &s, &l_max) && !feof(stdin) ) {
	printf("%s\n", s);
    }
    FREE(s);
    if ( !feof(stdin) ) {
	fprintf(stderr, "Str_GetLn failed.\n%s\n", Err_Get());
	exit(EXIT_FAILURE);
    }

    return 0;
}
END

# Build the test application
CFLAGS="-g -Wall -Wmissing-prototypes"
if ! cc ${CFLAGS} -o str5 str5.c src/str.c src/err_msg.c src/alloc.c
then
    echo "Could not build str5 from str5.c"
    $RM str5.c str
    exit 1
fi

# Test 1
echo "$0: test 1"
cat > correct << END
line 1
line 2
END
export MEM_DEBUG=2
if ! ./str5 < correct > attempt 2> memtrace
then
    echo "Test application failed to run."
    exit 1
fi
if diff correct attempt
then
    echo "Str_GetLn driver produced correct output."
else
    echo "String driver failed!"
    exit 1
fi
echo ""

echo "Checking memory trace (will not say anything if no leaks)"
src/chkalloc < memtrace
echo "Memory check done"
echo "$0 done with test 1"
echo ""
$RM correct attempt memtrace

# Test 2
echo "$0: test 2"
cat > correct << END
line 1

END
export MEM_DEBUG=2
if ! ./str5 < correct > attempt 2> memtrace
then
    echo "Test application failed to run."
    exit 1
fi
if diff correct attempt
then
    echo "Str_GetLn driver produced correct output."
else
    echo "String driver failed!"
    exit 1
fi
echo ""

echo "Checking memory trace (will not say anything if no leaks)"
src/chkalloc < memtrace
echo "Memory check done"
echo "$0 done with test 2"

$RM str5.c str5 correct attempt memtrace
echo "Done with str5 test"

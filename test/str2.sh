#!/bin/sh
#
#- str2.sh --
#-	This test application tests string manipulation functions defined
#-	in str.c.  The driver application reads strings from stdin
#-	and substitutes characters associated with escape sequences that
#-	it finds.
#-
# Copyright (c) 2009 Gordon D. Carrie
# All rights reserved
#
# Please send feedback to dev0@trekix.net
#
# $Revision: 1.3 $ $Date: 2009/10/07 17:06:47 $
#
########################################################################

echo "
str2.sh - test Str_Esc function.

Usage suggestions:
$0 2>&1 | less
To save temporary files:
env RM=: $0 2>&1 | less

Copyright (c) 2009 Gordon D. Carrie
All rights reserved

################################################################################
"

# Set RM to : in environment to save temporary files.
RM=${RM:-'rm -f'}

#
CC="cc"
CFLAGS="-g -Wall -Wmissing-prototypes"
MSRC="str2.c"
SRC="$MSRC src/str.c src/err_msg.c src/alloc.c"
EXEC="str2"

# Here is the source code for the driver application
cat > $MSRC << END
#include <string.h>
#include <stdio.h>
#include "src/str.h"

int main()
{
    char s[0xffff];

    while ( fgets(s, 0xfffe, stdin) ) {
	Str_Esc(s);
	printf("%s", s);
    }
    return 0;
}
END

# Build the test application
if ! $CC $CFLAGS -Isrc -o $EXEC $SRC
then
    echo "Build failed."
    exit 1
fi

# The test application should produce this output
cat > ${EXEC}.out << END
Now is the time ...
Now is the time
to party.
Now is the time to party. Ha!999
Now is the time to party. H!
Now is the time to party!
END

# Run the test
echo "Testing $EXEC"
if ( ./$EXEC << "END"
Now is the time ...
Now is the time\nto party.
Now is the time to party. \0110\0141\041999
Now is the time to party. \0110\041
Now is the time to party\041
END
) | diff ${EXEC}.out - 
then
    echo "$EXEC produced correct output."
    result1=success
else
    echo "$EXEC produced bad output."
    result1=fail
fi
$RM ${EXEC}.out
echo "test1 result = $result1
Done with test1

################################################################################
"

$RM $MSRC $EXEC ${EXEC}.out

#!/bin/sh
#
#- mstring1.sh --
#-	This test application tests string manipulation functions defined
#-	in msrtring.c.  The driver application reads strings from stdin
#-	and substitutes characters associated with escape sequences that
#-	it finds.
#-
# Copyright (c) 2009 Gordon D. Carrie
# All rights reserved
#
# Please send feedback to dev0@trekix.net
#
# $Revision: 1.1 $ $Date: 2009/07/06 20:27:31 $
#
########################################################################

echo "
mstring.sh --
This test application tests string manipulation functions defined
in msrtring.c.  The driver application reads strings from stdin
and substitutes characters associated with escape sequences that
it finds.

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
MSRC="mstring1.c"
SRC="$MSRC src/mstring.c"
EXEC="mstring1"

# Here is the source code for the driver application
cat > $MSRC << END
#include <string.h>
#include <stdio.h>
#include <mstring.h>

int main()
{
    char s[0xffff];

    while ( fgets(s, 0xfffe, stdin) ) {
	stresc(s);
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

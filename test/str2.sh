#!/bin/sh
#
#- str2.sh --
#-	This test application tests string manipulation functions defined
#-	in str.c.  The driver application reads strings from stdin
#-	and substitutes characters associated with escape sequences that
#-	it finds.
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
# $Revision: 1.5 $ $Date: 2011/11/28 16:11:23 $
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
CC="cc -std=c99"
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

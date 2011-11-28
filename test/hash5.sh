#!/bin/sh
#
#- hash5.sh --
#-	This test application tests the hash table interface defined in src/hash.c.
#-	It monitors a process that creates a small hash table and prints it.
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
# $Revision: 1.2 $ $Date: 2010/11/19 05:33:49 $
#
########################################################################

# This is the remove command.  Change this to : to retain intermediate results.

RM=${RM:-'rm -f'}

# Here is the source code for the test application.

cat > hash5.c << END
#include <stdio.h>
#include <hash.h>
#include <err_msg.h>

int main(void)
{
    struct Hash_Tbl tbl;

    if ( !Hash_Init(&tbl, 4) ) {
	fprintf(stderr, "Could not initialize hash table.\n");
	fprintf(stderr, "%s\n", Err_Get());
    }
    if ( !Hash_Set(&tbl, "foo", (void *)16)
	    || !Hash_Set(&tbl, "bar", (void *)32)
	    || !Hash_Set(&tbl, "hello", (void *)33)
	    || !Hash_Set(&tbl, "world", (void *)64) ) {
	fprintf(stderr, "Failed to set values in hash table.\n");
	fprintf(stderr, "%s\n", Err_Get());
    }
    Hash_Print(&tbl);
    Hash_Clear(&tbl);
    return 0;
}
END

# Output from the application should match the contents of file correct.

cat << END > correct
[]
[]
[(world 0x40)(hello 0x21)(foo 0x10)]
[(bar 0x20)]
END

# Build, run, and evaluate the test application

echo "Running the hash test"
echo "Putting test values into file \"attempt\""
echo "Putting memory trace into file \"memtrace\""
COPT='-g -Wall -Wmissing-prototypes -Isrc/'
export MEM_DEBUG=2
if cc $COPT -o hash hash5.c src/hash.c src/err_msg.c src/alloc.c
then
    ./hash > attempt 2> memtrace
else
    echo Could not build hash from hash5.c
    exit 1
fi
echo ''
echo 'hash driver is done'

# Compare the output from the test "attempt" with the "correct"

if diff correct attempt
then
    echo "hash driver produced correct output"
    $RM attempt hash
else
    echo "hash driver failed!"
    exit 1
fi
unset MEM_DEBUG
echo ''

echo 'Checking memory trace (will not say anything if no leaks)'
src/chkalloc < memtrace
echo 'Memory check done'

$RM correct memtrace hash5.c

echo 'Done with hash5 test'

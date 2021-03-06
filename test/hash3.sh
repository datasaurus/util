#!/bin/sh
#
#- hash3.sh --
#-	This test application tests the hash table interface defined in src/hash.c.
#-	It examines a process that creates a small hash table and then clears it
#-	one entry at a time while printing a memory trace.
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
# $Revision: 1.17 $ $Date: 2014/01/24 22:34:25 $
#
########################################################################

# This is the remove command.  Change this to : to retain intermediate results.

#RM=:
RM='rm -f'

# Here is the source code for the test application.

cat > hash3.c << END
#include <stdio.h>
#include <alloc.h>
#include <err_msg.h>
#include <hash.h>

void hash_print(struct Hash_Tbl *tblP, char *key);

void hash_print(struct Hash_Tbl *tblP, char *key)
{
    int *np;

    if ( (np = Hash_Get(tblP, key)) ) {
	printf("%s -> %d\n", key, *np);
    } else {
	fprintf(stderr, "Entry for %s disappeared from table.\n", "foo");
    }
}

int main(void)
{
    struct Hash_Tbl tbl;
    int n;
    char *keys[] = {
	"foo", "bar", "hello", "world"
    };
    int vals[] = {
	0, 1, 10, 11
    };
    int v2;

    if ( !Hash_Init(&tbl, 4) ) {
	fprintf(stderr, "Could not initialize hash table.\n");
	fprintf(stderr, "%s\n", Err_Get());
    }
    if ( !Hash_Set(&tbl, "foo", vals + 0)
	    || !Hash_Set(&tbl, "bar", vals + 1)
	    || !Hash_Set(&tbl, "hello", vals + 2)
	    || !Hash_Set(&tbl, "world", vals + 3) ) {
	fprintf(stderr, "Failed to set values in hash table.\n");
	fprintf(stderr, "%s\n", Err_Get());
    }
    for (n = 0; n < 4; n++) {
	hash_print(&tbl, keys[n]);
    }

    printf("Modifying table.\n");
    v2 = 4;
    if ( !Hash_Set(&tbl, "bar", &v2) ) {
	fprintf(stderr, "Failed to set value in hash table.\n");
	fprintf(stderr, "%s\n", Err_Get());
    }
    for (n = 0; n < 4; n++) {
	hash_print(&tbl, keys[n]);
    }

    printf("Modifying table recklessly.\n");
    if ( !Hash_Add(&tbl, "bar", &v2) ) {
	printf("Failed to add entry for \"bar\".  Error message was:\n%s\n",
		Err_Get());
    }

    printf("Clearing table.\n");
    Hash_Rm(&tbl, "foo");
    Hash_Rm(&tbl, "bar");
    Hash_Rm(&tbl, "hello");
    Hash_Rm(&tbl, "world");

    return 0;
}
END

# Output from the application should match the contents of file correct.

cat << END > correct
foo -> 0
bar -> 1
hello -> 10
world -> 11
Modifying table.
foo -> 0
bar -> 4
hello -> 10
world -> 11
Modifying table recklessly.
Failed to add entry for "bar".  Error message was:
bar in use.

Clearing table.
END

# Build and run the test application, with memory trace.

echo "Running the hash test"
echo "Putting test values into file \"attempt\""
echo "Putting memory trace into file \"memtrace\""
COPT='-std=c99 -g -Wall -Wmissing-prototypes -Isrc/ -DMEM_DEBUG'
export MEM_DEBUG=2
if cc $COPT -o hash hash3.c src/hash.c src/err_msg.c src/alloc.c src/strlcpy.c
then
    ./hash > attempt 2> memtrace
else
    echo Could not build hash from hash3.c
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
    echo "TEST COMPLETE. hash driver failed!"
    exit 1
fi
unset MEM_DEBUG
echo ''

echo 'Checking memory trace'
echo 'There should be one "leak" because this test does not delete the table, '
echo 'just the entries.'
src/chkalloc < memtrace
echo 'Memory check done'

$RM correct memtrace hash3.c

echo 'Done with hash3 test'

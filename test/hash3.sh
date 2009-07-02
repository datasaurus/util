#!/bin/sh
#
#- hash3.sh --
#-	This test application tests the hash table interface defined in src/hash.c.
#-	It examines a process that creates a small hash table and then clears it
#-	one entry at a time while printing a memory trace.
#-
# Copyright (c) 2008 Gordon D. Carrie
#
# Licensed under the Open Software License version 3.0
#
# Please send feedback to dev0@trekix.net
#
# $Revision: 1.11 $ $Date: 2008/12/19 19:24:19 $
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

void hash_print(struct hash_tbl *tblP, char *key);

void hash_print(struct hash_tbl *tblP, char *key)
{
    unsigned n;

    if (hash_get(tblP, key, &n)) {
	printf("%s -> %d\n", key, n);
    } else {
	fprintf(stderr, "Entry for %s disappeared from table.\n", "foo");
    }
}

int main(void)
{
    struct hash_tbl tbl;
    int n;
    char *keys[] = {
	"foo", "bar", "hello", "world"
    };

    if ( !hash_init(&tbl, 4) ) {
	fprintf(stderr, "Could not initialize hash table.\n");
	fprintf(stderr, "%s\n", err_get());
    }
    if ( !hash_set(&tbl, "foo", 0)
	    || !hash_set(&tbl, "bar", 1)
	    || !hash_set(&tbl, "hello", 10)
	    || !hash_set(&tbl, "world", 11) ) {
	fprintf(stderr, "Failed to set values in hash table.\n");
	fprintf(stderr, "%s\n", err_get());
    }
    for (n = 0; n < 4; n++) {
	hash_print(&tbl, keys[n]);
    }

    printf("Modifying table.\n");
    if ( !hash_set(&tbl, "bar", 2) ) {
	fprintf(stderr, "Failed to set value in hash table.\n");
	fprintf(stderr, "%s\n", err_get());
    }
    for (n = 0; n < 4; n++) {
	hash_print(&tbl, keys[n]);
    }

    printf("Modifying table recklessly.\n");
    if ( !hash_add(&tbl, "bar", 3) ) {
	printf("Failed to add entry for \"bar\".  Error message was:\n%s\n",
		err_get());
    }

    printf("Clearing table.\n");
    hash_rm(&tbl, "foo");
    hash_rm(&tbl, "bar");
    hash_rm(&tbl, "hello");
    hash_rm(&tbl, "world");

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
bar -> 2
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
COPT='-g -Wall -Wmissing-prototypes -Isrc/ -DMEM_DEBUG'
export MEM_DEBUG=2
if cc $COPT -o hash hash3.c src/hash.c src/err_msg.c src/alloc.c
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

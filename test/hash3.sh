#!/bin/sh
#
# This script tests the hash table interface in src.
#
# Copyright (c) 2008 Gordon D. Carrie
#
# Licensed under the Open Software License version 3.0
#
# Please send feedback to user0@tkgeomap.org
#
# $Id: hash3.sh,v 1.5 2008/11/11 21:20:29 gcarrie Exp $
#
########################################################################

# This is the remove command.  Change this to : to retain intermediate results.

#RM=:
RM='rm -f'

# The test application creates a small hash table and then clears it one entry
# at a time while printing a memory trace.

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

    hash_init(&tbl, 4);
    hash_add(&tbl, "foo", 0);
    hash_add(&tbl, "bar", 1);
    hash_add(&tbl, "hello", 10);
    hash_add(&tbl, "world", 11);
    for (n = 0; n < 4; n++) {
	hash_print(&tbl, keys[n]);
    }

    printf("Modifying table.\n");
    hash_set(&tbl, "bar", 2);
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

    err_destroy();
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

COPT='-g -Wall -Wmissing-prototypes -Isrc/ -DMEM_DEBUG'
export MEM_DEBUG=2
if cc $COPT -o hash hash3.c src/hash.c src/err_msg.c src/alloc.c
then
    echo 'Running app from hash3.c with memory trace going to memtrace.'
    ./hash > attempt 2> memtrace
else
    echo Could not build hash from hash3.c
    exit 1
fi
if diff correct attempt
then
    echo "TEST COMPLETE. hash driver produced correct output"
    echo ''
    $RM attempt hash
else
    echo "TEST COMPLETE. hash driver failed!"
    exit 1
fi
unset MEM_DEBUG

echo 'Memory report'
echo 'There should be one \"leak\" because this test does not delete the table, '
echo 'just the entries.'
src/findleaks < memtrace
echo 'Memory check done'

$RM correct memtrace hash3.c

echo 'Done with hash3 test'

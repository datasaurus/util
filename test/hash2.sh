#!/bin/sh

# This script tests the hash table interface in visky3.
#
# $Id: hash2.sh,v 1.4 2008/10/30 21:11:34 gcarrie Exp $

# This is the remove command.  Change this to : to retain intermediate results.

RM='rm -f'
FINDLEAKS=src/findleaks

# The test application creates a small hash table and modifies it.  It also
# prints a memory trace.

# Here is the source code for the test application.

cat > hash2.c << END
#include <stdio.h>
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
    hash_set(&tbl, "foo", 0);
    hash_set(&tbl, "bar", 1);
    hash_set(&tbl, "hello", 10);
    hash_set(&tbl, "world", 11);
    for (n = 0; n < 4; n++) {
	hash_print(&tbl, keys[n]);
    }

    printf("Modifying table.\n");
    hash_set(&tbl, "bar", 2);
    for (n = 0; n < 4; n++) {
	hash_print(&tbl, keys[n]);
    }

    hash_clear(&tbl);
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
END

# Build, run, and evaluate the test application

COPT='-g -Wall -Wmissing-prototypes -Isrc/ -DMEM_DEBUG'
if cc $COPT -o hash hash2.c src/hash.c src/err_msg.c src/alloc.c
then
    echo 'Running app from hash2.c with memory trace going to memtest.'
    ./hash > attempt 2> memtrace
else
    echo Could not build hash from hash2.c
    exit 1
fi
if diff correct attempt
then
    echo "TEST COMPLETE.  hash driver produced correct output"
    echo ''
    $RM attempt hash
else
    echo "TEST COMPLETE.  hash driver failed!"
    exit 1
fi

echo 'Memory report (will not say anything if no leaks)'
$FINDLEAKS < memtrace
echo 'Memory check done'

$RM correct memtrace hash2.c

echo 'Done with hash2 test'

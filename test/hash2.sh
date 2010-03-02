#!/bin/sh
#
#- hash2.sh --
#-	This test application tests the hash table interface defined in src/hash.c.
#-	It monitors a process that creates a small hash table and modifies it.
#-
# Copyright (c) 2008 Gordon D. Carrie
# All rights reserved
#
# Please send feedback to dev0@trekix.net
#
# $Revision: 1.14 $ $Date: 2010/03/02 15:27:29 $
#
########################################################################

# This is the remove command.  Change this to : to retain intermediate results.
RM=${RM:-'rm -f'}

# Here is the source code for the test application.
cat > hash2.c << END
#include <stdio.h>
#include <hash.h>
#include <err_msg.h>

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
	1, 2, 10, 11
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

    Hash_Clear(&tbl);
    return 0;
}
END

# Output from the application should match the contents of file correct.

cat << END > correct
foo -> 1
bar -> 2
hello -> 10
world -> 11
Modifying table.
foo -> 1
bar -> 4
hello -> 10
world -> 11
END

# Build, run, and evaluate the test application

echo "Running the hash test"
echo "Putting test values into file \"attempt\""
echo "Putting memory trace into file \"memtrace\""
COPT='-g -Wall -Wmissing-prototypes -Isrc/'
export MEM_DEBUG=2
if cc $COPT -o hash hash2.c src/hash.c src/err_msg.c src/alloc.c
then
    ./hash > attempt 2> memtrace
else
    echo Could not build hash from hash2.c
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

$RM correct memtrace hash2.c

echo 'Done with hash2 test'

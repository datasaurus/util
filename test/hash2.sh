#!/bin/sh

# This script tests the hash table interface in visky3.
#
# $Id: hash2.sh,v 1.1 2008/10/01 21:16:23 gcarrie Exp $

# This test uses hash2.c.  The driver application creates a small
# hash table and modifies it.  It also prints a memory trace.

# This is the remove command.  Change this to : to retain intermediate results.

RM='rm -f'

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
COPT='-g -Wall -Wmissing-prototypes -Isrc/ -DMEM_DEBUG'
if cc $COPT -o hash hash2.c src/hash.c src/alloc.c
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
awk '
    /(0x)?[0-9]+.* allocated / {
	cnt[$1]++
    }
    /(0x)?[0-9]+.* freed / {
	cnt[$1]--
    }
    END {
	for (a in cnt) {
	    if (cnt[a] > 0) {
		printf "Leak at %s\n", a
	    }
	}
    }
' memtrace
echo 'Memory check done'

$RM correct memtrace

echo 'Done with hash2 test'

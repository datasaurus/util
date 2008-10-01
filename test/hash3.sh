#!/bin/sh

# This script tests the hash table interface in visky3.
#
# $Id$

# This test uses hash3.c.  The driver application creates a small
# hash table and then clears it one entry at a time while printing
# a memory trace.

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
Clearing table.
END
COPT='-g -Wall -Wmissing-prototypes -Isrc/ -DMEM_DEBUG'
if cc $COPT -o hash hash3.c src/hash.c src/alloc.c
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
    rm -f attempt hash
else
    echo "TEST COMPLETE. hash driver failed!"
    exit 1
fi

echo 'Memory report'
echo 'There should be one \"leak\" because this test does not delete the table, '
echo 'just the entries.'
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

rm -f correct memtrace

echo 'Done with hash3 test'

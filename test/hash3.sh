#!/bin/sh

# This script tests the hash table interface in visky3.
#
# $Id: hash3.sh,v 1.3 2008/10/02 21:09:45 gcarrie Exp $

# This test uses hash3.c.  The driver application creates a small
# hash table and then clears it one entry at a time while printing
# a memory trace.

# This is the remove command.  Change this to : to retain intermediate results.

RM='rm -f'
FINDLEAKS=src/findleaks

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
COPT='-g -Wall -Wmissing-prototypes -Isrc/ -DMEM_DEBUG'
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

echo 'Memory report'
echo 'There should be one \"leak\" because this test does not delete the table, '
echo 'just the entries.'
$FINDLEAKS < memtrace
echo 'Memory check done'

$RM correct memtrace

echo 'Done with hash3 test'

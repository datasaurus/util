#!/bin/sh

# This script tests the hash table interface in visky3.
#
# $Id: hash4.sh,v 1.2 2008/10/01 21:34:02 gcarrie Exp $

# This test uses hash4.c.  The driver application creates a small
# hash table and then resizes it while printing a memory trace.

# Identify a file of whitespace separated words.

WORD_FL=/usr/share/dict/words

# This is the remove command.  Change this to : to retain intermediate results.

RM='rm -f'

# Get the number of words and length of the longest word.

NWORD=`cat ${WORD_FL} | wc -l`
NWORD=`printf "%d" $NWORD`
LMAX=`awk '
    BEGIN {
	lmax=-1
    }
    {
	l=length($1)
	if (l > lmax) {
	    lmax = l
	}
    }
    END {
	printf "%d", lmax
    }' ${WORD_FL}`

# Pick out some random words for the test.  Put them into file "correct"

echo "Creating a list of keys and indeces from $WORD_FL"
imax=`expr $NWORD - 1`
echo "Putting test values into file \"correct\""
awk -v nword=$NWORD \
	'BEGIN {
	    i=0
	};
	{
	    w[i]=$1;i++
	};
	END {
	    for (i=0;i<10;i++) {
		ii=int(nword*rand());printf "%d %s\n", ii, w[ii]
	    }
	}' \
    $WORD_FL > correct

# Build and run the driver application.  Put its output into the file "attempt"

COPT='-g -Wall -Wmissing-prototypes -Isrc/ -DMEM_DEBUG'

echo "Running the hash test"
CFLAGS="${COPT} -DWORD_FL=\"${WORD_FL}\" \
	-DNWORD=${NWORD} -DNBUCKET=${NWORD} -DLMAX=${LMAX}"
if cc ${CFLAGS} -o hash hash4.c src/hash.c src/err_msg.c src/alloc.c
then
    echo 'Running app from hash4.c with memory trace going to memtrace.'
    awk '{printf "%s ", $2}' correct | ./hash > attempt 2> memtrace
else
    echo Could not build hash from hash4.c
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

echo 'Done with hash4 test'

#!/bin/sh

# This script tests the hash table interface in visky3.
#
# $Id: hash1.sh,v 1.1 2008/10/01 21:14:10 gcarrie Exp $

# This test uses hash1.c.  The driver application reads a stream of words
# into a hash table and then tries to retrieve some of them.

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

COPT='-g -Wall -Wmissing-prototypes -Isrc/'

echo "Running the hash test"
echo "Putting test values into file \"attempt\""
CFLAGS="${COPT} -DWORD_FL=\"${WORD_FL}\" \
	-DNWORD=${NWORD} -DNBUCKET=${NWORD} -DLMAX=${LMAX}"
if cc ${CFLAGS} -o hash hash1.c src/hash.c
then
    awk '{printf "%s ", $2}' correct | ./hash > attempt
else
    echo 'Could not build hash from hash1.c'
    echo ''
    $RM correct attempt
    exit 1
fi

# Compare the output from the test "attempt" with the "correct"

if diff correct attempt
then
    echo "TEST COMPLETE. hash driver produced correct output"
    echo ''
    $RM attempt hash
else
    echo "TEST COMPLETE. hash driver failed!"
    echo ''
    exit 1
fi

# Repeat with a smaller hash table.

echo "Running the hash test with excessively small hash table"
echo "Putting test values into file \"attempt\""
CFLAGS="${COPT} -DWORD_FL=\"${WORD_FL}\" \
	-DNWORD=${NWORD} -DNBUCKET=`expr ${NWORD} / 4` -DLMAX=${LMAX}"
if cc ${CFLAGS} -o hash hash1.c src/hash.c
then
    awk '{printf "%s ", $2}' correct | ./hash > attempt
else
    echo Could not build hash from hash1.c
    $RM correct attempt
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

$RM correct

echo 'Done with hash1 test'

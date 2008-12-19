#!/bin/sh
#
# This script tests the hash table interface defined in src.
#
# Copyright (c) 2008 Gordon D. Carrie
#
# Licensed under the Open Software License version 3.0
#
# Please send feedback to dev0@trekix.net
#
# $Revision$ $Date$
#
########################################################################

# This is the remove command.  Change this to : to retain intermediate results.

RM='rm -f'

# This test creates an application that reads a stream of words
# into a hash table and then tries to retrieve some of them.

# Identify a file of whitespace separated words, WORD_FL.

WORD_FL=/usr/share/dict/words

# Get the number of words, NWORD, and length of the longest word, LMAX.

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

# The test application will read words from WORD_FL and store them in a hash
# table. Hash values for each word will be its line index from WORD_FL.
# The process will then read words from standard input.
# For each word, it will print the word and its index from WORD_FL.

# Here is the source code for the test application.
# NBUCKET will be defined at compile time, depending on the type of test.

cat > hash1.c << END
#include <stdlib.h>
#include <stdio.h>
#include <hash.h>

char keys[$NWORD][$LMAX];

int main(void)
{
    struct hash_tbl tbl;
    char *word_fl = "$WORD_FL";
    FILE *in;
    unsigned n;
    char key[$LMAX];

    fprintf(stderr, "Running hash driver with %d buckets for %d words.\n",
	    NBUCKET, $NWORD);
    hash_init(&tbl, NBUCKET);
    if ( !(in = fopen(word_fl, "r")) ) {
	fprintf(stderr, "Could not open %s\n", word_fl);
	exit(1);
    }
    for (n = 0; fscanf(in, " %s", keys[n]) == 1; n++) {
	hash_set(&tbl, keys[n], n);
    }
    fclose(in);

    while (scanf(" %s", key) == 1) {
	if (hash_get(&tbl, key, &n)) {
	    printf("%u %s\n", n, key);
	} else {
	    fprintf(stderr, "No entry for %s\n", key);
	    exit(1);
	}
    }

    hash_clear(&tbl);
    return 0;
}
END

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

echo "Running the hash test"
echo "Putting test values into file \"attempt\""
COPT='-g -Wall -Wmissing-prototypes -Isrc/'
NBUCKET=${NWORD}
CFLAGS="${COPT} -DNBUCKET=${NBUCKET}"
if cc ${CFLAGS} -o hash hash1.c src/err_msg.c src/hash.c src/alloc.c
then
    awk '{printf "%s ", $2}' correct | ./hash > attempt
else
    echo 'Could not build hash from hash1.c'
    $RM correct attempt
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
echo ''

# Repeat with a smaller hash table.

echo "Running the hash test with excessively small hash table"
echo "Putting test values into file \"attempt\""
NBUCKET=`expr ${NWORD} / 4`
CFLAGS="${COPT} -DNBUCKET=${NBUCKET}"
if cc ${CFLAGS} -o hash hash1.c src/err_msg.c src/hash.c src/alloc.c
then
    awk '{printf "%s ", $2}' correct | ./hash > attempt
else
    echo Could not build hash from hash1.c
    $RM correct attempt
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
echo ''

$RM correct hash1.c
echo 'Done with hash1 test'

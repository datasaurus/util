#!/bin/sh
#
#- hash4.sh --
#-	This test application tests the hash table interface defined in src/hash.c.
#-	It examines a process that creates a small hash table and then resizes
#-	it while printing a memory trace.
# Copyright (c) 2011, Gordon D. Carrie. All rights reserved.
# 
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# 
#     * Redistributions of source code must retain the above copyright
#     notice, this list of conditions and the following disclaimer.
#     * Redistributions in binary form must reproduce the above copyright
#     notice, this list of conditions and the following disclaimer in the
#     documentation and/or other materials provided with the distribution.
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
# A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
# HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
# SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
# TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
# PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
# LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
# NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
# Please send feedback to dev0@trekix.net
#
# $Revision: 1.15 $ $Date: 2010/11/27 03:21:20 $
#
########################################################################

# This is the remove command.  Change this to : to retain intermediate results.

RM=${RM:-'rm -f'}

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
NBUCKET=$NWORD

# The test application will read WORD_FL from from standard input.
# For each word, it will print the word and its index from WORD_FL.
# Then it will resize the hash table a couple of times and repeat.

# Here is the source code for the test application.

cat > hash4.c << END
#include <stdlib.h>
#include <stdio.h>
#include <err_msg.h>
#include <hash.h>

char keys[$NWORD][$LMAX];
int indeces[$NWORD];

int main(void)
{
    struct Hash_Tbl tbl;
    char *word_fl = "$WORD_FL";
    FILE *in;
    int n, *np;
    char key[$LMAX];

    fprintf(stderr, "Running hash driver with %d buckets for %d words.\n",
	    $NBUCKET, $NWORD);
    Hash_Init(&tbl, $NBUCKET);
    if ( !(in = fopen(word_fl, "r")) ) {
	fprintf(stderr, "Could not open %s\n", word_fl);
	exit(1);
    }
    for (n = 0; fscanf(in, " %s", keys[n]) == 1; n++) {
	indeces[n] = n;
	if ( !Hash_Set(&tbl, keys[n], indeces + n) ) {
	    fprintf(stderr, "Could not set value in hash table.\n");
	    fprintf(stderr, "%s\n", Err_Get());
	    exit(1);
	}
    }
    fclose(in);

    n = $NBUCKET / 4;
    fprintf(stderr, "Adjusting table to %d buckets for %d words.\n", n, $NWORD);
    if ( !Hash_Adj(&tbl, n) ) {
	fprintf(stderr, "Could not adjust hash table size.\n");
	fprintf(stderr, "%s\n", Err_Get());
	exit(1);
    }

    n = $NBUCKET * 2;
    fprintf(stderr, "Adjusting table to %d buckets for %d words.\n", n, $NWORD);
    if ( !Hash_Adj(&tbl, n) ) {
	fprintf(stderr, "Could not adjust hash table size.\n");
	fprintf(stderr, "%s\n", Err_Get());
	exit(1);
    }

    /*
       Retrieve some entries from the resized table.
     */

    while (scanf(" %s", key) == 1) {
	if ( (np = Hash_Get(&tbl, key)) ) {
	    printf("%d %s\n", *np, key);
	} else {
	    printf("No entry for %s\n", key);
	    exit(1);
	}
    }

    Hash_Clear(&tbl);
    return 0;
}
END

# Pick out some random words for the test.  Put them into file "correct"

echo "Creating a list of keys and indices from $WORD_FL"
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
echo "Putting memory trace into file \"memtrace\""
COPT='-g -Wall -Wmissing-prototypes -Isrc/'
CFLAGS="${COPT}"
export MEM_DEBUG=3
if cc ${CFLAGS} -o hash hash4.c src/hash.c src/err_msg.c src/alloc.c
then
    awk '{printf "%s ", $2}' correct | ./hash > attempt 2> hash.err 3> memtrace
else
    echo Could not build hash from hash4.c
    exit 1
fi
echo ''
echo 'hash driver is done'

# Compare the output from the test "attempt" with the "correct"

if diff correct attempt
then
    echo "hash driver produced correct output"
    echo ''
    $RM attempt hash
else
    echo "hash driver failed!"
    exit 1
fi
unset MEM_DEBUG

echo 'Checking memory trace (will not say anything if no leaks)'
src/chkalloc < memtrace
echo 'Memory check done'

$RM correct memtrace hash4.c hash.err

echo 'Done with hash4 test'

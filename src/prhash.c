/*
   -	prhash.c --
   -		This application grows a hash table to perfection and then
   -		prints it.
   -	
   .	Usage:
   .		prhash word1 word2 ...
   .
   .	Output will be from Hash_Print.  All entries will have value 1 (arbitrary).
   .
   .	Copyright (c) 2009 Gordon D. Carrie
   .	All rights reserved
   .
   .	Please send feedback to dev0@trekix.net
   .
   .	$Revision: 1.1 $ $Date: 2009/12/21 20:21:25 $
 */

#include <stdio.h>
#include "err_msg.h"
#include "hash.h"

int main(int argc, char *argv[])
{
    struct Hash_Tbl h;
    char **a;
    unsigned b, e, bb;

    if ( !Hash_Init(&h, (unsigned)(argc - 1)) ) {
	fprintf(stderr, "Could not create hash table.\n");
	exit(EXIT_FAILURE);
    }
    for (a = argv + 1; *a; a++) {
	if ( !Hash_Add(&h, *a, 1) ) {
	    fprintf(stderr, "Could not add \"%s\".\n%s\n", *a, Err_Get());
	    exit(EXIT_FAILURE);
	}
    }
    Hash_Sz(&h, &b, &e, &bb);
    for (b++ ; bb > 1; b++) {
	if ( !Hash_Adj(&h, b) ) {
	    fprintf(stderr, "Could not grow hash table.\n");
	    exit(EXIT_FAILURE);
	}
	Hash_Sz(&h, &b, &e, &bb);
    }
    Hash_Print(&h);
    return 0;
}

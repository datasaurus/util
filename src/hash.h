/*
   -	hash.h --
   -		This file declares hash table functions
   -		and data structures.
   -		See hash (3).
   -	
   .	Copyright (c) 2008 Gordon D. Carrie
   .	All rights reserved
   .
   .	Please send feedback to dev0@trekix.net
   .
   .	$Revision: 1.17 $ $Date: 2009/10/01 22:15:22 $
 */

#ifndef HASH_H_
#define HASH_H_

#include <stdlib.h>

/* Hash table entry */
struct Hash_Entry {
    char *key;				/* String identifier */
    int val;				/* Value associated with string */
    struct Hash_Entry *next;		/* Pointer to next entry in bucket
					 * chain */
};

/* Hash table */
struct Hash_Tbl {
    struct Hash_Entry **buckets;	/* Bucket array.  Each element is a
					 * linked list of entries */
    unsigned n_buckets;
    unsigned n_entries;
};

/* Global functions */
int Hash_Init(struct Hash_Tbl *, unsigned);
void Hash_Clear(struct Hash_Tbl *);
int Hash_Add(struct Hash_Tbl *, const char *, int);
int Hash_Set(struct Hash_Tbl *, const char *, int);
int Hash_Get(struct Hash_Tbl *, const char *, int *);
int Hash_Adj(struct Hash_Tbl *, unsigned);
void Hash_Rm(struct Hash_Tbl *, const char *);
void Hash_Sz(struct Hash_Tbl *, unsigned *, unsigned *);

#endif

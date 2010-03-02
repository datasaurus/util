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
   .	$Revision: 1.21 $ $Date: 2009/12/21 20:40:52 $
 */

#ifndef HASH_H_
#define HASH_H_

#include <stdlib.h>

#define HASH_X 31

/* Hash table entry */
struct Hash_Entry {
    char *key;				/* String identifier */
    void *val;				/* Value associated with string */
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
unsigned Hash(const char *, unsigned);
int Hash_Add(struct Hash_Tbl *, const char *, void *);
int Hash_Set(struct Hash_Tbl *, const char *, void *);
void * Hash_Get(struct Hash_Tbl *, const char *);
void Hash_Print(struct Hash_Tbl *tblP);
int Hash_Adj(struct Hash_Tbl *, unsigned);
void Hash_Rm(struct Hash_Tbl *, const char *);
void Hash_Sz(struct Hash_Tbl *, unsigned *, unsigned *, unsigned *);

#endif

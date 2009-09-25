/*
 - hash.h --
 - 	This file declares hash table functions and data structures.
 -
   Copyright (c) 2008 Gordon D. Carrie
   All rights reserved

   Please send feedback to dev0@trekix.net

   $Revision: 1.15 $ $Date: 2009/07/03 19:40:52 $
 */

#ifndef HASH_H_
#define HASH_H_

#include <stdlib.h>

/* Hash table entry */
struct hash_entry {
    char *key;				/* String identifier */
    int val;				/* Value associated with string */
    struct hash_entry *next;		/* Pointer to next entry in bucket
					 * chain */
};

/* Hash table */
struct hash_tbl {
    struct hash_entry **buckets;	/* Bucket array.  Each element is a
					 * linked list of entries */
    unsigned n_buckets;
    unsigned n_entries;
};

/* Global functions */
int hash_init(struct hash_tbl *, unsigned);
void hash_clear(struct hash_tbl *);
int hash_add(struct hash_tbl *, const char *, int);
int hash_set(struct hash_tbl *, const char *, int);
int hash_get(struct hash_tbl *, const char *, int *);
int hash_adj(struct hash_tbl *, unsigned);
void hash_rm(struct hash_tbl *, const char *);
void hash_sz(struct hash_tbl *, unsigned *, unsigned *);

#endif

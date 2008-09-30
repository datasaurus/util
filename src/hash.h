/*
 * hash --
 *
 * 	This file declares hash table functions and data structures.
 *
 *  Copyright (c) 2008 Gordon D. Carrie
 *
 * Licensed under the Open Software License version 2.1
 *
 * Please send feedback to user0@tkgeomap.org
 *
 * $Id: hash.h,v 1.5 2008/09/30 19:25:55 tkgeomap Exp $
 *
 *************************************************************************
 */

#ifndef HASH_H_
#define HASH_H_

#ifdef __cplusplus
extern "C" {
#endif

#include <stdlib.h>

/*
 * Hash table entry structure.
 */

struct hash_entry {
    char *key;				/* String identifier */
    unsigned val;			/* Value associated with string */
    struct hash_entry *next;		/* Pointer to next entry in bucket
					 * chain */
};

/*
 * Hash table structure.
 */

struct hash_tbl {
    struct hash_entry **buckets;	/* Bucket array.  Each element is a
					 * linked list of entries */
    unsigned n_buckets;
    unsigned n_entries;
};

/*
 * Global hash table functions.
 */

void hash_init(struct hash_tbl *, unsigned);
void hash_clear(struct hash_tbl *);
int hash_add(struct hash_tbl *, const char *, unsigned val);
void hash_set(struct hash_tbl *, const char *, unsigned val);
long hash_get(struct hash_tbl *, const char *);
void hash_rm(struct hash_tbl *, const char *);
    
#ifdef __cplusplus
}
#endif

#endif

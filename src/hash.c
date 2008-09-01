/*
 * hash --
 *
 * 	This file defines hash table functions.
 *
 * 	Reference:
 * 	Kernighan, Brian W. and Rob Pike
 * 	The practice of programming
 * 	Reading, Massachusetts
 * 	1999
 *
 *  Copyright (c) 2008 Gordon D. Carrie
 *
 * Licensed under the Open Software License version 2.1
 *
 * Please send feedback to user0@tkgeomap.org
 *
 * $Id$
 *
 *************************************************************************
 */

#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include "alloc.h"
#include "hash.h"

#define HASH_X 31

static unsigned hash(const char *, unsigned);

/*
 *----------------------------------------------------------------------
 *
 * hash -
 * 
 * 	Retrieve an index in a hash table given the key.
 *
 * Arguments:
 * 	char *k		- string key
 * 	unsigned n	- number of buckets in hash table
 *
 *----------------------------------------------------------------------
 */

static unsigned hash(const char *k, unsigned n)
{
    unsigned h;

    for (h = 0 ; *k != '\0'; k++) {
	h = HASH_X * h + (unsigned)*k;
    }
    return h % n;
}

/*
 *----------------------------------------------------------------------
 *
 * hash_init --
 *
 * 	This constructor initializes a new hash table.
 *
 * Arguments:
 * 	tblP		- pointer to space for a hash table.
 *			  Contents should be garbage.
 *	n_entries	- number of entries that will be stored.  Table will
 *			  not grow, but may become crowded, if this number
 *			  of entries is eventually exceeded.
 *
 * Side effects:
 *	If n_entries > 0, memory is allocated in the table.
 *	If n_entries == 0, the table is initialized with bogus values.
 *	It should not be used, but is safe to give to hash_clear.
 *
 *----------------------------------------------------------------------
 */

void hash_init(struct hash_tbl *tblP, size_t n_entries)
{
    size_t sz;
    struct hash_entry *ep;		/* Pointer into entry array */
    struct hash_entry **bp;		/* Pointer into bucket array */

    tblP->entries = NULL;
    tblP->n_entries = 0;
    tblP->buckets = NULL;
    tblP->n_buckets = 0;
    if (n_entries == 0) {
	return;
    }
    tblP->n_entries = n_entries;
    tblP->n_buckets = 2 * n_entries;
    if (tblP->n_buckets % HASH_X == 0) {
	tblP->n_buckets++;
    }
    sz = tblP->n_buckets * sizeof(struct hash_entry *);
    tblP->buckets = (struct hash_entry **)MALLOC(sz);
    for (bp = tblP->buckets; bp < tblP->buckets + tblP->n_buckets; bp++) {
	*bp = NULL;
    }
    sz = n_entries * sizeof(struct hash_entry);
    tblP->entries = (struct hash_entry *)MALLOC(sz);
    for (ep = tblP->entries; ep < tblP->entries + n_entries; ep++) {
	ep->key = NULL;
	ep->next = NULL;
    }
}

/*
 *----------------------------------------------------------------------
 *
 * hash_clear --
 *
 * 	This destructor empties a hash table.
 *
 * Arguments:
 * 	struct hash_tbl *tblP	- pointer to a hash table.
 *
 * Side effects:
 * 	Memory associated with the table is freed and the table is
 * 	reinitialized.
 *
 *----------------------------------------------------------------------
 */

void hash_clear(struct hash_tbl *tblP)
{
    struct hash_entry *ep, *entries;
    unsigned n_entries;

    if ( !tblP ) {
	return;
    }
    entries = tblP->entries;
    n_entries = tblP->n_entries;
    if (entries) {
	for (ep = entries; ep < entries + n_entries; ep++) {
	    FREE(ep->key);
	}
    }
    FREE(tblP->entries);
    FREE(tblP->buckets);
    hash_init(tblP, 0);
}

/*
   Add a value to a hash table.
 */

void hash_set(struct hash_tbl *tblP, const char *key, unsigned val)
{
    size_t len;
    struct hash_entry *ep;
    unsigned b;

    if ( !tblP->entries || !tblP->buckets ) {
	fprintf(stderr, "Attempted to use uninitialized hash table.\n");
	exit(1);
    }
    ep = (struct hash_entry *)MALLOC(sizeof(struct hash_entry));
    len = strlen(key);
    ep->key = (char *)MALLOC(len + 1);
    strcpy(ep->key, key);
    ep->val = val;
    b = hash(ep->key, tblP->n_buckets);
    ep->next = tblP->buckets[b];
    tblP->buckets[b] = ep;
}

/*
 *----------------------------------------------------------------------
 *
 * hash_get --
 *
 * 	This function retrieves a value from a hash table.
 *
 *
 * Arguments:
 *	struct hash_tbl *tblP	- pointer to space for a hash table.
 *	char *key		- string key.
 *
 * Results:
 *	Return value is value for key, or -1 if none.
 *
 *----------------------------------------------------------------------
 */

long hash_get(struct hash_tbl *tblP, const char *key)
{
    unsigned b;			/* Index into buckets array */
    struct hash_entry *ep;	/* Hash entry */

    b = hash(key, tblP->n_buckets);
    for (ep = tblP->buckets[b]; ep; ep = ep->next) {
	if (strcmp(ep->key, key) == 0) {
	    return ep->val;
	}
    }
    return -1;
}

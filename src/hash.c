/*
 * hash --
 *
 * 	This file defines hash table functions.
 *
 * 	Reference:
 * 	Kernighan, Brian W. and Rob Pike
 * 	The Practice of Programming
 * 	Reading, Massachusetts
 * 	1999
 *
 * Copyright (c) 2008 Gordon D. Carrie
 *
 * Licensed under the Open Software License version 3.0
 *
 * Please send feedback to user0@tkgeomap.org
 *
 * $Id: hash.c,v 1.16 2008/11/11 22:52:10 gcarrie Exp $
 *
 *************************************************************************
 */

#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include "alloc.h"
#include "err_msg.h"
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
 *	n_buckets	- number of entries that will be stored.  Table will
 *			  not grow, but may become crowded, if this number
 *			  of entries is eventually exceeded.
 *
 * Side effects:
 *	If n_buckets > 0, memory is allocated in the table, and the table
 *	is ready for use.
 *	If n_buckets == 0, no memory is allocated, and the table is
 *	initialized with bogus values.  The table is not safe for use,
 *	but is safe to give to hash_clear.
 *
 *----------------------------------------------------------------------
 */

void hash_init(struct hash_tbl *tblP, unsigned n_buckets)
{
    size_t sz;
    struct hash_entry **bp;		/* Pointer into bucket array */

    tblP->n_buckets = tblP->n_entries = 0;
    tblP->buckets = NULL;
    tblP->n_buckets = 0;
    if (n_buckets == 0) {
	return;
    }
    tblP->n_buckets = n_buckets;
    if (tblP->n_buckets % HASH_X == 0) {
	tblP->n_buckets++;
    }
    sz = tblP->n_buckets * sizeof(struct hash_entry *);
    tblP->buckets = (struct hash_entry **)MALLOC(sz);
    for (bp = tblP->buckets; bp < tblP->buckets + tblP->n_buckets; bp++) {
	*bp = NULL;
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
    struct hash_entry **bp, **bp1, *ep;

    if ( !tblP ) {
	return;
    }
    for (bp = tblP->buckets, bp1 = bp + tblP->n_buckets; bp < bp1; bp++) {
	for (ep = *bp; ep; ep = ep->next) {
	    FREE(ep->key);
	    FREE(ep);
	}
    }
    FREE(tblP->buckets);
    hash_init(tblP, 0);
}

/*
   Add a value to a hash table.
 */

int hash_add(struct hash_tbl *tblP, const char *key, unsigned val)
{
    size_t len;
    struct hash_entry *ep, *p;
    unsigned b;
    char *s, *d;

    if ( !tblP || !tblP->buckets || !key ) {
	return 0;
    }
    b = hash(key, tblP->n_buckets);
    for (p = tblP->buckets[b]; p; p = p->next) {
	if (strcmp(p->key, key) == 0) {
	    err_append(key);
	    err_append(" in use.\n");
	    return 0;
	}
    }
    ep = (struct hash_entry *)MALLOC(sizeof(struct hash_entry));
    len = strlen(key);
    ep->key = (char *)MALLOC(len + 1);
    for (s = (char *)key, d = ep->key; *s; s++, d++) {
	*d = *s;
    }
    ep->val = val;
    ep->next = tblP->buckets[b];
    tblP->buckets[b] = ep;
    tblP->n_entries++;
    return 1;
}

/*
   Set a value in a hash table.
 */

void hash_set(struct hash_tbl *tblP, const char *key, unsigned val)
{
    size_t len;
    struct hash_entry *ep, *p;
    unsigned b;
    char *s, *d;

    if ( !tblP->buckets || !key ) {
	return;
    }
    b = hash(key, tblP->n_buckets);
    for (p = tblP->buckets[b]; p; p = p->next) {
	if (strcmp(p->key, key) == 0) {
	    p->val = val;
	    return;
	}
    }
    ep = (struct hash_entry *)MALLOC(sizeof(struct hash_entry));
    len = strlen(key);
    ep->key = (char *)MALLOC(len + 1);
    for (s = (char *)key, d = ep->key; *s; s++, d++) {
	*d = *s;
    }
    ep->val = val;
    ep->next = tblP->buckets[b];
    tblP->buckets[b] = ep;
    tblP->n_entries++;
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

int hash_get(struct hash_tbl *tblP, const char *key, unsigned *lp)
{
    unsigned b;			/* Index into buckets array */
    struct hash_entry *ep;	/* Hash entry */

    if ( !tblP || !tblP->n_buckets || !key ) {
	return 0;
    }
    b = hash(key, tblP->n_buckets);
    for (ep = tblP->buckets[b]; ep; ep = ep->next) {
	if (strcmp(ep->key, key) == 0) {
	    *lp = ep->val;
	    return 1;
	}
    }
    return 0;
}

/*
   Adjust the number of buckets in a hash table.
 */

void hash_adj(struct hash_tbl *tblP, unsigned n_buckets2)
{
    struct hash_entry **buckets2, **bp, **bp1, *ep, *next;
    unsigned b;
    size_t sz;

    if (n_buckets2 % HASH_X == 0) {
	n_buckets2++;
    }
    sz = n_buckets2 * sizeof(struct hash_entry *);
    buckets2 = (struct hash_entry **)MALLOC(sz);
    for (bp = buckets2, bp1 = bp + n_buckets2; bp < bp1; bp++) {
	*bp = NULL;
    }
    for (bp = tblP->buckets, bp1 = bp + tblP->n_buckets; bp < bp1; bp++) {
	for (ep = *bp; ep; ep = next) {
	    next = ep->next;
	    b = hash(ep->key, n_buckets2);
	    ep->next = buckets2[b];
	    buckets2[b] = ep;
	}
    }
    FREE(tblP->buckets);
    tblP->buckets = buckets2;
    tblP->n_buckets = n_buckets2;
}

/*
   Remove an entry from a hash table.
 */

void hash_rm(struct hash_tbl *tblP, const char *key)
{
    struct hash_entry *p, *prev;
    unsigned b;

    if ( !tblP->buckets || !key ) {
	return;
    }
    b = hash(key, tblP->n_buckets);
    p = tblP->buckets[b];
    for (prev = NULL, p = tblP->buckets[b]; p; prev = p, p = p->next) {
	if (strcmp(p->key, key) == 0) {
	    if (prev) {
		prev->next = p->next;
	    } else {
		tblP->buckets[b] = p->next;
	    }
	    FREE(p->key);
	    FREE(p);
	    tblP->n_entries--;
	    return;
	}
    }
}
/*
   Provide information about the size of a hash table.
 */

void hash_sz(struct hash_tbl *tblP, unsigned *n_bucketsP, unsigned *n_entriesP)
{
    if ( !tblP ) {
	return;
    }
    *n_bucketsP = tblP->n_buckets;
    *n_entriesP = tblP->n_entries;
}

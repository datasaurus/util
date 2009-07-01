/*
 - hash.c --
 - 	This file defines hash table functions.  See hash (3).
 -
   Copyright (c) 2008 Gordon D. Carrie
   Licensed under the Open Software License version 3.0

   Please send feedback to dev0@trekix.net

   $Revision: 1.20 $ $Date: 2008/12/17 22:55:56 $
*/

/*
   Reference:
	Kernighan, Brian W. and Rob Pike. The Practice of Programming.
	Reading, Massachusetts. 1999
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
 * hash - compute an index in a hash table given the key.
 * k = string key (in)
 * n = number of buckets in hash table (in)
 * Return value is a pseudo-random integer in range [0,n)
 */
static unsigned hash(const char *k, unsigned n)
{
    unsigned h;

    for (h = 0 ; *k != '\0'; k++) {
	h = HASH_X * h + (unsigned)*k;
    }
    return h % n;
}

/* See hash (3) */
int hash_init(struct hash_tbl *tblP, unsigned n_buckets)
{
    size_t sz;
    struct hash_entry **bp;		/* Pointer into bucket array */

    tblP->n_buckets = tblP->n_entries = 0;
    tblP->buckets = NULL;
    tblP->n_buckets = 0;
    if (n_buckets == 0) {
	return 1;
    }
    tblP->n_buckets = n_buckets;
    if (tblP->n_buckets % HASH_X == 0) {
	tblP->n_buckets++;
    }
    sz = tblP->n_buckets * sizeof(struct hash_entry *);
    tblP->buckets = (struct hash_entry **)MALLOC(sz);
    if ( !tblP->buckets ) {
	err_append("Could not allocate memory for hash table.\n");
	return 0;
    }
    for (bp = tblP->buckets; bp < tblP->buckets + tblP->n_buckets; bp++) {
	*bp = NULL;
    }
    return 1;
}

/* See hash (3) */
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

/* See hash (3) */
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
    if ( !ep ) {
	err_append("Could not allocate memory for new entry in hash table.\n");
	return 0;
    }
    len = strlen(key);
    ep->key = (char *)MALLOC(len + 1);
    if ( !ep->key ) {
	err_append("Could not allocate memory for new entry in hash table.\n");
	FREE(ep);
	return 0;
    }
    for (s = (char *)key, d = ep->key; *s; s++, d++) {
	*d = *s;
    }
    ep->val = val;
    ep->next = tblP->buckets[b];
    tblP->buckets[b] = ep;
    tblP->n_entries++;
    return 1;
}

/* See hash (3) */
int hash_set(struct hash_tbl *tblP, const char *key, unsigned val)
{
    size_t len;
    struct hash_entry *ep, *p;
    unsigned b;
    char *s, *d;

    if ( !tblP->buckets || !key ) {
	err_append("Attempted to set nonexistent hash table.\n");
	return 0;
    }
    b = hash(key, tblP->n_buckets);
    for (p = tblP->buckets[b]; p; p = p->next) {
	if (strcmp(p->key, key) == 0) {
	    p->val = val;
	    return 1;
	}
    }
    ep = (struct hash_entry *)MALLOC(sizeof(struct hash_entry));
    if ( !ep ) {
	err_append("Could not allocate memory for new entry in hash table.\n");
	return 0;
    }
    len = strlen(key);
    ep->key = (char *)MALLOC(len + 1);
    if ( !ep->key ) {
	err_append("Could not allocate memory for new entry in hash table.\n");
	FREE(ep);
	return 0;
    }
    for (s = (char *)key, d = ep->key; *s; s++, d++) {
	*d = *s;
    }
    ep->val = val;
    ep->next = tblP->buckets[b];
    tblP->buckets[b] = ep;
    tblP->n_entries++;
    return 1;
}

/* See hash (3) */
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

/* See hash (3) */
int hash_adj(struct hash_tbl *tblP, unsigned n_buckets2)
{
    struct hash_entry **buckets2, **bp, **bp1, *ep, *next;
    unsigned b;
    size_t sz;

    if (n_buckets2 % HASH_X == 0) {
	n_buckets2++;
    }
    sz = n_buckets2 * sizeof(struct hash_entry *);
    buckets2 = (struct hash_entry **)MALLOC(sz);
    if ( !buckets2 ) {
	err_append("Could not allocate memory when adjusting hash table size.\n");
	return 0;
    }
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
    return 1;
}

/* See hash (3) */
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

/* See hash (3) */
void hash_sz(struct hash_tbl *tblP, unsigned *n_bucketsP, unsigned *n_entriesP)
{
    if ( !tblP ) {
	return;
    }
    *n_bucketsP = tblP->n_buckets;
    *n_entriesP = tblP->n_entries;
}

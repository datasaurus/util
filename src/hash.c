/*
   -	hash.c --
   -		This file defines hash table functions.
   -		See hash (3).
   -	
   .	Copyright (c) 2008 Gordon D. Carrie
   .	All rights reserved
   .
   .	Please send feedback to dev0@trekix.net
   .
   .	$Revision: 1.31 $ $Date: 2010/11/01 22:20:44 $
   .
   .	Reference:
   .		Kernighan, Brian W. and Rob Pike.
   .		The Practice of Programming.
   .		Reading, Massachusetts. 1999
 */

#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include "alloc.h"
#include "err_msg.h"
#include "hash.h"


/*
 * hash - compute an index in a hash table given the key.
 * k = string key (in)
 * n = number of buckets in hash table (in)
 * Return value is a pseudo-random integer in range [0,n)
 */
unsigned Hash(const char *k, unsigned n)
{
    unsigned h;

    for (h = 0 ; *k != '\0'; k++) {
	h = HASH_X * h + (unsigned)*k;
    }
    return h % n;
}

/* See hash (3) */
int Hash_Init(struct Hash_Tbl *tblP, unsigned n_buckets)
{
    size_t sz;
    struct Hash_Entry **bp;		/* Pointer into bucket array */

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
    sz = tblP->n_buckets * sizeof(struct Hash_Entry *);
    tblP->buckets = (struct Hash_Entry **)MALLOC(sz);
    if ( !tblP->buckets ) {
	Err_Append("Could not allocate memory for hash table.\n");
	return 0;
    }
    for (bp = tblP->buckets; bp < tblP->buckets + tblP->n_buckets; bp++) {
	*bp = NULL;
    }
    return 1;
}

/* See hash (3) */
void Hash_Clear(struct Hash_Tbl *tblP)
{
    struct Hash_Entry **bp, **bp1, *ep, *ep1;

    if ( !tblP ) {
	return;
    }
    for (bp = tblP->buckets, bp1 = bp + tblP->n_buckets; bp < bp1; bp++) {
	for (ep = *bp; ep; ep = ep1) {
	    ep1 = ep->next;
	    FREE(ep->key);
	    FREE(ep);
	}
    }
    FREE(tblP->buckets);
    Hash_Init(tblP, 0);
}

/* See hash (3) */
int Hash_Add(struct Hash_Tbl *tblP, const char *key, void * val)
{
    size_t len;
    struct Hash_Entry *ep, *p;
    unsigned b;
    char *s, *d;

    if ( !tblP || !tblP->buckets || !key ) {
	return 0;
    }
    b = Hash(key, tblP->n_buckets);
    for (p = tblP->buckets[b]; p; p = p->next) {
	if (strcmp(p->key, key) == 0) {
	    Err_Append(key);
	    Err_Append(" in use.\n");
	    return 0;
	}
    }
    ep = (struct Hash_Entry *)MALLOC(sizeof(struct Hash_Entry));
    if ( !ep ) {
	Err_Append("Could not allocate memory for new entry in hash table.\n");
	return 0;
    }
    len = strlen(key);
    ep->key = (char *)MALLOC(len + 1);
    if ( !ep->key ) {
	Err_Append("Could not allocate memory for new entry in hash table.\n");
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
int Hash_Set(struct Hash_Tbl *tblP, const char *key, void *val)
{
    size_t len;
    struct Hash_Entry *ep, *p;
    unsigned b;
    char *s, *d;

    if ( !tblP->buckets || !key ) {
	Err_Append("Attempted to set nonexistent hash table.\n");
	return 0;
    }
    b = Hash(key, tblP->n_buckets);
    for (p = tblP->buckets[b]; p; p = p->next) {
	if (strcmp(p->key, key) == 0) {
	    p->val = val;
	    return 1;
	}
    }
    ep = (struct Hash_Entry *)MALLOC(sizeof(struct Hash_Entry));
    if ( !ep ) {
	Err_Append("Could not allocate memory for new entry in hash table.\n");
	return 0;
    }
    len = strlen(key);
    ep->key = (char *)MALLOC(len + 1);
    if ( !ep->key ) {
	Err_Append("Could not allocate memory for new entry in hash table.\n");
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
void * Hash_Get(struct Hash_Tbl *tblP, const char *key)
{
    unsigned b;			/* Index into buckets array */
    struct Hash_Entry *ep;	/* Hash entry */

    if ( !tblP || !tblP->n_buckets || !key ) {
	return 0;
    }
    b = Hash(key, tblP->n_buckets);
    for (ep = tblP->buckets[b]; ep; ep = ep->next) {
	if (strcmp(ep->key, key) == 0) {
	    return ep->val;
	}
    }
    return NULL;
}

/* See hash (3) */
void Hash_Print(struct Hash_Tbl *tblP)
{
    struct Hash_Entry **bp, **bp1, *ep;

    if ( !tblP ) {
	return;
    }
    for (bp = tblP->buckets, bp1 = bp + tblP->n_buckets; bp < bp1; bp++) {
	printf("[");
	for (ep = *bp; ep; ep = ep->next) {
	    printf("(%s %p)", ep->key, ep->val);
	}
	printf("]\n");
    }
}

/* See hash (3) */
int Hash_Adj(struct Hash_Tbl *tblP, unsigned n_buckets2)
{
    struct Hash_Entry **buckets2, **bp, **bp1, *ep, *next;
    unsigned b;
    size_t sz;

    if (n_buckets2 % HASH_X == 0) {
	n_buckets2++;
    }
    sz = n_buckets2 * sizeof(struct Hash_Entry *);
    buckets2 = (struct Hash_Entry **)MALLOC(sz);
    if ( !buckets2 ) {
	Err_Append("Could not allocate memory when adjusting hash table size.\n");
	return 0;
    }
    for (bp = buckets2, bp1 = bp + n_buckets2; bp < bp1; bp++) {
	*bp = NULL;
    }
    for (bp = tblP->buckets, bp1 = bp + tblP->n_buckets; bp < bp1; bp++) {
	for (ep = *bp; ep; ep = next) {
	    next = ep->next;
	    b = Hash(ep->key, n_buckets2);
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
void Hash_Rm(struct Hash_Tbl *tblP, const char *key)
{
    struct Hash_Entry *p, *p1, *prev;
    unsigned b;

    if ( !tblP->buckets || !key ) {
	return;
    }
    b = Hash(key, tblP->n_buckets);
    p = tblP->buckets[b];
    for (prev = NULL, p = p1 = tblP->buckets[b]; p; prev = p, p = p1) {
	p1 = p->next;
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
void Hash_Sz(struct Hash_Tbl *tblP, unsigned *n_bucketsP, unsigned *n_entriesP,
	unsigned *biggestP)
{
    struct Hash_Entry **bp, **bp1, *ep;

    if ( !tblP ) {
	return;
    }
    *n_bucketsP = tblP->n_buckets;
    *n_entriesP = tblP->n_entries;
    for (*biggestP = 0, bp = tblP->buckets, bp1 = bp + tblP->n_buckets;
	    bp < bp1;
	    bp++) {
	unsigned c;

	for (c = 0, ep = *bp; ep; ep = ep->next) {
	    c++;
	}
	*biggestP = (c > *biggestP) ? c : *biggestP;
    }
}

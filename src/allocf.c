/*
 * allocf.c --
 *
 *	This file defines functions that allocate multi-dimensional
 *	arrays of floating point values.  See allocf (3) for
 *	documentation.
 * 
 * Copyright (c) 2008 Gordon D. Carrie
 *
 * Licensed under the Open Software License version 3.0
 *
 * Please send feedback to user0@tkgeomap.org
 *
 * $Id: allocf.c,v 1.6 2008/11/12 04:13:45 gcarrie Exp $
 *
 **********************************************************************
 *
 */

#include <assert.h>
#include "alloc.h"
#include "allocf.h"

float ** mallocf2(size_t j, size_t i)
{
    float **dat = NULL;		/* Return value */
    long n;			/* Loop parameter */
    long jj, ii;		/* Addends for pointer arithmetic */

    jj = (long)j;
    ii = (long)i;
    assert((double)jj == (double)j && (double)ii == (double)i);
    dat = (float **)CALLOC(j, sizeof(float *));
    if ( !dat ) {
	return NULL;
    }
    dat[0] = (float *)CALLOC(j * i, sizeof(float));
    if ( !dat[0] ) {
	FREE(dat);
	return NULL;
    }
    for (n = 1; n < jj; n++) {
	dat[n] = dat[n - 1] + ii;
    }
    return dat;
}

void freef2(float **dat)
{
    if (dat && dat[0]) {
	FREE(dat[0]);
    }
    FREE(dat);
}

float *** mallocf3(size_t k, size_t j, size_t i)
{
    float ***dat;		/* Return value */
    long n, ne;			/* Loop parameters */
    long kk, jj, ii;		/* Addends for pointer arithmetic */

    kk = (long)k;
    jj = (long)j;
    ii = (long)i;
    assert((double)kk == (double)k && (double)jj == (double)j
	    && (double)ii == (double)i);
    dat = (float ***)CALLOC(k, sizeof(float **));
    if ( !dat ) {
	return NULL;
    }
    dat[0] = (float **)CALLOC(k * j, sizeof(float *));
    if ( !dat[0] ) {
	FREE(dat);
	return NULL;
    }
    dat[0][0] = (float *)CALLOC(k * j * i, sizeof(float));
    if ( !dat[0][0] ) {
	FREE(dat[0]);
	FREE(dat);
	return NULL;
    }
    for (n = 1; n < kk; n++) {
	dat[n] = dat[n - 1] + jj;
    }
    for (n = 1, ne = kk * jj; n < ne; n++) {
	dat[0][n] = dat[0][n - 1] + ii;
    }
    return dat;
}

void freef3(float ***dat)
{
    if (dat) {
	if (dat[0]) {
	    if (dat[0][0]) {
		FREE(dat[0][0]);
	    }
	    FREE(dat[0]);
	}
	FREE(dat);
    }
}

float **** mallocf4(size_t l, size_t k, size_t j, size_t i)
{
    float ****dat;		/* Return value */
    long n, ne;			/* Loop parameters */
    long ll, kk, jj, ii;	/* Addends for pointer arithmetic */

    ll = (long)l;
    kk = (long)k;
    jj = (long)j;
    ii = (long)i;
    assert((double)ll == (double)l && (double)kk == (double)k
	    && (double)jj == (double)j && (double)ii == (double)i);
    dat = (float ****)CALLOC(l, sizeof(float ***));
    if ( !dat ) {
	return NULL;
    }
    dat[0] = (float ***)CALLOC(l * k, sizeof(float **));
    if ( !dat[0] ) {
	FREE(dat);
	return NULL;
    }
    dat[0][0] = (float **)CALLOC(l * k * j, sizeof(float *));
    if ( !dat[0][0] ) {
	FREE(dat[0]);
	FREE(dat);
	return NULL;
    }
    dat[0][0][0] = (float *)CALLOC(l * k * j * i, sizeof(float));
    if ( !dat[0][0][0] ) {
	FREE(dat[0][0]);
	FREE(dat[0]);
	FREE(dat);
	return NULL;
    }
    for (n = 1; n < ll; n++) {
	dat[n] = dat[n - 1] + kk;
    }
    for (n = 1, ne = ll * kk; n < ne; n++) {
	dat[0][n] = dat[0][n - 1] + jj;
    }
    for (n = 1, ne = ll * kk * jj; n < ne; n++) {
	dat[0][0][n] = dat[0][0][n - 1] + ii;
    }
    return dat;
}

void freef4(float ****dat)
{
    if (dat) {
	if (dat[0]) {
	    if (dat[0][0]) {
		if (dat[0][0][0]) {
		    FREE(dat[0][0][0]);
		}
		FREE(dat[0][0]);
	    }
	    FREE(dat[0]);
	}
	FREE(dat);
    }
}

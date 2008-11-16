/*
 * allocf.c --
 *
 *	This file defines functions that allocate multi-dimensional
 *	arrays of floating point values.  See allocf (3).
 * 
 * Copyright (c) 2008 Gordon D. Carrie
 *
 * Licensed under the Open Software License version 3.0
 *
 * Please send feedback to user0@tkgeomap.org
 *
 * $Id: allocf.c,v 1.10 2008/11/15 22:36:31 gcarrie Exp $
 *
 **********************************************************************
 *
 */

#include "alloc.h"
#include "err_msg.h"
#include "allocf.h"

float ** mallocf2(size_t j, size_t i)
{
    float **dat = NULL;
    long n;
    long jj, ii;		/* Addends for pointer arithmetic */
    size_t ji;

    jj = (long)j;
    ii = (long)i;
    ji = j * i;
    if ( (double)jj != (double)j || (double)ii != (double)i
	    || (double)j * (double)i != (double)(ji)) {
	err_append("Dimensions too big for pointer arithmetic.\n");
	return NULL;
    }
    dat = (float **)CALLOC(j, sizeof(float *));
    if ( !dat ) {
	err_append("Could not allocate memory.\n");
	return NULL;
    }
    dat[0] = (float *)CALLOC(ji, sizeof(float));
    if ( !dat[0] ) {
	FREE(dat);
	err_append("Could not allocate memory.\n");
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
    float ***dat = NULL;
    long n, ne;
    long kk, jj, ii;		/* Addends for pointer arithmetic */
    size_t kj, kji;

    kk = (long)k;
    jj = (long)j;
    ii = (long)i;
    kj = k * j;
    kji = kj * i;
    if (       (double)kk != (double)k
	    || (double)jj != (double)j
	    || (double)ii != (double)i
	    || (double)k * (double)j * (double)i != (double)(kji)) {
	err_append("Dimensions too big for pointer arithmetic.\n");
	return NULL;
    }
    dat = (float ***)CALLOC(k, sizeof(float **));
    if ( !dat ) {
	err_append("Could not allocate memory.\n");
	return NULL;
    }
    dat[0] = (float **)CALLOC(kj, sizeof(float *));
    if ( !dat[0] ) {
	FREE(dat);
	err_append("Could not allocate memory.\n");
	return NULL;
    }
    dat[0][0] = (float *)CALLOC(kji, sizeof(float));
    if ( !dat[0][0] ) {
	FREE(dat[0]);
	FREE(dat);
	err_append("Could not allocate memory.\n");
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
    float ****dat;
    long n, ne;
    long ll, kk, jj, ii;	/* Addends for pointer arithmetic */
    size_t lk, lkj, lkji;

    ll = (long)l;
    kk = (long)k;
    jj = (long)j;
    ii = (long)i;
    lk = l * k;
    lkj = lk * j;
    lkji = lkj * i;
    if ((double)ll != (double)l || (double)kk != (double)k
	    || (double)jj != (double)j || (double)ii != (double)i
	    || (double)l * (double)k * (double)j * (double)i != (double)lkji) {
	err_append("Dimensions too big for pointer arithmetic.\n");
	return NULL;
    }
    dat = (float ****)CALLOC(l, sizeof(float ***));
    if ( !dat ) {
	err_append("Could not allocate memory.\n");
	return NULL;
    }
    dat[0] = (float ***)CALLOC(lk, sizeof(float **));
    if ( !dat[0] ) {
	FREE(dat);
	err_append("Could not allocate memory.\n");
	return NULL;
    }
    dat[0][0] = (float **)CALLOC(lkj, sizeof(float *));
    if ( !dat[0][0] ) {
	FREE(dat[0]);
	FREE(dat);
	err_append("Could not allocate memory.\n");
	return NULL;
    }
    dat[0][0][0] = (float *)CALLOC(lkji, sizeof(float));
    if ( !dat[0][0][0] ) {
	FREE(dat[0][0]);
	FREE(dat[0]);
	FREE(dat);
	err_append("Could not allocate memory.\n");
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

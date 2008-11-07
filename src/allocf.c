/*
 * alloc.c --
 *
 *	This file defines functions that allocate multi-dimensional
 *	arrays of floating point values.
 * 
 * Copyright (c) 2008 Gordon D. Carrie
 *
 * Licensed under the Open Software License version 3.0
 *
 * Please send feedback to user0@tkgeomap.org
 *
 * $Id: allocf.c,v 1.2 2008/11/06 17:09:42 gcarrie Exp $
 *
 **********************************************************************
 *
 */

#include "allocf.h"

/*
 *------------------------------------------------------------------------
 *
 * mallocf2 --
 *
 * 	This function allocates a 2 dimensional array.
 *
 * Arguments:
 *	size_t j	- size of 2nd dimension
 *	size_t i	- size of 1st dimension
 *
 * Results:
 * 	Return value is the address of a three dimensional array
 * 	dimensioned [j][i].
 *
 * Side effects:
 * 	Memory is allocated.  It should eventually be freed with a call to
 *	freef2.
 *
 *------------------------------------------------------------------------
 */

float ** mallocf2(size_t j, size_t i)
{
    float **dat;		/* Return value */
    long n;			/* Loop parameter */

    dat = (float **)CALLOC(j, sizeof(float *));
    dat[0] = (float *)CALLOC(j * i, sizeof(float));
    for (n = 1; n < jj; n++) {
	dat[n] = dat[n - 1] + ii;
    }
    return dat;
}

/*
 *------------------------------------------------------------------------
 *
 * freef2 --
 *
 * 	This function frees an array allocated with mallocf2.
 *
 * Arguments:
 *	float **dat	- address returned by mallocf2.
 *
 * Results:
 * 	None.
 *
 * Side effects:
 * 	Memory is freed.
 *
 *------------------------------------------------------------------------
 */

void freef2(float **dat)
{
    if (dat && dat[0])
	FREE(dat[0]);
    FREE(dat);
}

/*
 *------------------------------------------------------------------------
 *
 * mallocf3 --
 *
 * 	This function allocates a 3 dimensional array.
 *
 * Arguments:
 *	size_t k	- size of 3rd dimension
 *	size_t j	- size of 2nd dimension
 *	size_t i	- size of 1st dimension
 *
 * Results:
 * 	Return value is the address of a three dimensional array
 * 	dimensioned [k][j][i].
 *
 * Side effects:
 * 	Memory is allocated.  It should eventually be freed with a call to
 *	freef3.
 *
 *------------------------------------------------------------------------
 */

float *** mallocf3(size_t k, size_t j, size_t i)
{
    float ***dat;		/* Return value */
    unsigned n, ne;		/* Loop parameters */

    dat = (float ***)CALLOC(k, sizeof(float **));
    dat[0] = (float **)CALLOC(k * j, sizeof(float *));
    dat[0][0] = (float *)CALLOC(k * j * i, sizeof(float));
    for (n = 1; n < k; n++) {
	dat[n] = dat[n - 1] + j;
    }
    for (n = 1, ne = k * j; n < ne; n++) {
	dat[0][n] = dat[0][n - 1] + i;
    }
    return dat;
}

/*
 *------------------------------------------------------------------------
 *
 * freef3 --
 *
 * 	This function frees an array allocated with mallocf3.
 *
 * Arguments:
 *	float ***dat	- address returned by mallocf3.
 *
 * Results:
 * 	None.
 *
 * Side effects:
 * 	Memory is freed.
 *
 *------------------------------------------------------------------------
 */

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

/*
 *------------------------------------------------------------------------
 *
 * mallocf4 --
 *
 * 	This function allocates a 4 dimensional array.
 *
 * Arguments:
 *	size_t l	- size of 4th dimension
 *	size_t k	- size of 3rd dimension
 *	size_t j	- size of 2nd dimension
 *	size_t i	- size of 1st dimension
 *
 * Results:
 * 	Return value is the address of a four dimensional array.
 *
 * Side effects:
 * 	Memory is allocated.  It should eventually be freed with a call to
 *	freef4.
 *
 *------------------------------------------------------------------------
 */

float **** mallocf4(size_t l, size_t k, size_t j, size_t i)
{
    float ****dat;		/* Return value */
    unsigned n, ne;		/* Loop parameters */

    dat = (float ****)CALLOC(l, sizeof(float ***));
    dat[0] = (float ***)CALLOC(l * k, sizeof(float **));
    dat[0][0] = (float **)CALLOC(l * k * j, sizeof(float *));
    dat[0][0][0] = (float *)CALLOC(l * k * j * i, sizeof(float));
    for (n = 1; n < l; n++) {
	dat[n] = dat[n - 1] + k;
    }
    for (n = 1, ne = l * k; n < ne; n++) {
	dat[0][n] = dat[0][n - 1] + j;
    }
    for (n = 1, ne = l * k * j; n < ne; n++) {
	dat[0][0][n] = dat[0][0][n - 1] + i;
    }
    return dat;
}

/*
 *------------------------------------------------------------------------
 *
 * freef4 --
 *
 * 	This function frees an array allocated with mallocf4.
 *
 * Arguments:
 *	float ****dat	- address returned by mallocf4.
 *
 * Results:
 * 	None.
 *
 * Side effects:
 * 	Memory is freed.
 *
 *------------------------------------------------------------------------
 */

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

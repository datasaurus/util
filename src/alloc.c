/*
 * alloc.c --
 *
 *	This file defines memory allocators.
 * 
 * Copyright (c) 2007, 2008 Gordon D. Carrie
 *
 * Licensed under the Open Software License version 2.1
 *
 * Please send feedback to user0@tkgeomap.org
 *
 * @(#) $Id: alloc.c,v 1.1 2008/09/01 17:54:58 tkgeomap Exp $
 *
 **********************************************************************
 *
 */

#include <assert.h>
#include <stdio.h>
#include "alloc.h"

/*
 * This counter records the number of times an allocator
 * has been called.  It helps to sort output for debugging.
 */

static unsigned c;

/*
 *------------------------------------------------------------------------
 *
 * malloc_nrm --
 *
 *	This is a front end to malloc
 *
 * Arguments:
 * 	size_t sz	- number of bytes to allocate
 *
 * Results:
 * 	Memory is allocated with malloc.  Return value is return value of
 * 	malloc.
 *
 * Side effects:
 *	If the attempt to allocate memory fails, the process aborts.
 *
 *------------------------------------------------------------------------
 */

void *malloc_nrm(size_t sz)
{
    void *m;

    m = malloc(sz);
    assert(m);
    return m;
}

/*
 *------------------------------------------------------------------------
 *
 * realloc_mdb --
 *
 *	This is a front end to realloc.
 *
 * Arguments:
 * 	void *m		- address of memory to reallocate.
 * 	size_t sz	- number of bytes to allocate
 *
 * Results:
 * 	Memory is reallocated with realloc.  Return value is return value of
 * 	realloc.
 *
 * Side effects:
 *	If the attempt to allocate memory fails, the process aborts.
 *
 *------------------------------------------------------------------------
 */

void *realloc_mdb(void *m, size_t sz)
{
    m = realloc(m, sz);
    assert(m);
    return m;
}

/*
 *------------------------------------------------------------------------
 *
 * malloc_mdb --
 *
 * 	This allocator with debugging support allocates memory and prints
 * 	information.
 *
 * Arguments:
 * 	size_t sz	- number of bytes to allocate
 * 	char *fl_nm	- string, assumed to be name of file where allocation
 *			  occurs.
 * 	int ln		- line number in fl_nm where allocation occurs.
 *
 * Results:
 * 	Memory is allocated with malloc.  Return value is return value of
 * 	malloc.  Information about where the allocation occurred is printed
 * 	to stderr.
 *
 *------------------------------------------------------------------------
 */

void *malloc_mdb(size_t sz, char *fl_nm, int ln)
{
    void *m;

    m = malloc(sz);
    fprintf(stderr, "%p (%09x) allocated at %s:%d\n", m, ++c, fl_nm, ln);
    return m;
}

/*
 *------------------------------------------------------------------------
 *
 * realloc_mdb --
 *
 * 	This allocator with debugging support reallocates memory and prints
 * 	information.
 *
 * Arguments:
 * 	void *m		- address of memory to reallocate.
 * 	size_t sz	- number of bytes to allocate
 * 	char *fl_nm	- string, assumed to be name of file where allocation
 *			  occurs.
 * 	int ln		- line number in fl_nm where allocation occurs.
 *
 * Results:
 * 	Memory is reallocated with realloc.  Return value is return value of
 * 	realloc.  Information about where the reallocation occurred is printed
 * 	to stderr.
 *
 *------------------------------------------------------------------------
 */

void *realloc_mdb(void *m, size_t sz, char *fl_nm, int ln)
{
    void *m2;

    m2 = realloc(m, sz);
    if (m2 != m) {
	if (m) {
	    fprintf(stderr, "%p (%09x) freed by realloc at %s:%d\n",
		    m, ++c, fl_nm, ln);
	}
	fprintf(stderr, "%p (%09x) allocated by realloc at %s:%d\n",
		m2, ++c, fl_nm, ln);
    } else {
	fprintf(stderr, "%p (%09x) reallocated at %s:%d\n", m, ++c, fl_nm, ln);
    }
    return m2;
}

/*
 *------------------------------------------------------------------------
 *
 * free_mdb --
 *
 * 	This deallocator with debugging support frees memory and prints
 * 	information.
 *
 * Arguments:
 * 	void *m		- address of memory to free.
 * 	char *fl_nm	- string, assumed to be name of file where allocation
 *			  occurs.
 * 	int ln		- line number in fl_nm where allocation occurs.
 *
 * Results:
 * 	Memory is freed with free.  Information about where the reallocation
 * 	occurred is printed to stderr.
 *
 *------------------------------------------------------------------------
 */

void free_mdb(void *m, char *fl_nm, int ln)
{
    fprintf(stderr, "%p (%09x) freed at %s:%d\n", m, ++c, fl_nm, ln);
    free(m);
}

/*
 *------------------------------------------------------------------------
 *
 * Alloc_Arr3 --
 *
 * 	This function allocates a 3 dimensional array.
 *
 * Arguments:
 *	size_t i	- size of 1st dimension
 *	size_t j	- size of 2nd dimension
 *	size_t k	- size of 3rd dimension
 *
 * Results:
 * 	Return value is the address of a three dimensional array
 * 	dimensioned [i][j][k].
 *
 * Side effects:
 * 	Memory is allocated.  It should eventually be freed with a call to
 *	Alloc_Free3.
 *
 *------------------------------------------------------------------------
 */

float *** Alloc_Arr3(size_t i, size_t j, size_t k)
{
    float ***dat;		/* Return value */
    unsigned n, ne;		/* Loop parameters */

    /*
     * There will be separate allocations for each dimension.
     *
     * Here's a cartoon example for
     * i = 2, j = 3, k = 4:
     *
     * Address	Symbol		Value
     * static	dat		0x0010
     * 
     * 0x0010	dat[0]		0x0100
     * 0x0014	dat[1]		0x010c
     * 
     * 0x0100	dat[0][0]	0x1000
     * 0x0104	dat[0][1]	0x1010
     * 0x0108	dat[0][2]	0x1020
     * 0x010c	dat[1][0]	0x1030
     * 0x0110	dat[1][1]	0x1040
     * 0x0114	dat[1][2]	0x1050
     * 
     * 0x1000	dat[0][0][0]
     * 0x1004	dat[0][0][1]
     * 0x1008	dat[0][0][2]
     * 0x100c	dat[0][0][3]
     * 0x1010	dat[0][1][0]
     * 0x1014	dat[0][1][1]
     * 0x1018	dat[0][1][2]
     * 0x101c	dat[0][1][3]
     * 0x1020	dat[0][2][0]
     * 0x1024	dat[0][2][1]
     * 0x1028	dat[0][2][2]
     * 0x102c	dat[0][2][3]
     * 0x1030	dat[1][0][0]
     * 0x1034	dat[1][0][1]
     * 0x1038	dat[1][0][2]
     * 0x103c	dat[1][0][3]
     * 0x1040	dat[1][1][0]
     * 0x1044	dat[1][1][1]
     * 0x1048	dat[1][1][2]
     * 0x104c	dat[1][1][3]
     * 0x1050	dat[1][2][0]
     * 0x1054	dat[1][2][1]
     * 0x1058	dat[1][2][2]
     * 0x105c	dat[1][2][3]
     *
     *************************************************************
     */

    dat = (float ***)MALLOC(i * sizeof(float **));
    dat[0] = (float **)MALLOC(i * j * sizeof(float *));
    dat[0][0] = (float *)MALLOC(i * j * k * sizeof(float));
    for (n = 1; n < i; n++) {
	dat[n] = dat[n - 1] + j;
    }
    for (n = 1, ne = i * j; n < ne; n++) {
	dat[0][n] = dat[0][n - 1] + k;
    }
    return dat;
}

/*
 *------------------------------------------------------------------------
 *
 * Alloc_Free3 --
 *
 * 	This function frees an array allocated with Alloc_Arr3.
 *
 * Arguments:
 *	float ***dat	- address returned by Alloc_Arr3.
 *
 * Results:
 * 	None.
 *
 * Side effects:
 * 	Memory is freed.
 *
 *------------------------------------------------------------------------
 */

void Alloc_Free3(float ***dat)
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
 * Alloc_Arr4 --
 *
 * 	This function allocates a 4 dimensional array.
 *
 * Arguments:
 *	size_t i	- size of 1st dimension
 *	size_t j	- size of 2nd dimension
 *	size_t k	- size of 3rd dimension
 *	size_t l	- size of 4th dimension
 *
 * Results:
 * 	Return value is the address of a four dimensional array.
 *
 * Side effects:
 * 	Memory is allocated.  It should eventually be freed with a call to
 *	Alloc_Free4.
 *
 *------------------------------------------------------------------------
 */

float **** Alloc_Arr4(size_t i, size_t j, size_t k, size_t l)
{
    float ****dat;		/* Return value */
    unsigned n, ne;		/* Loop parameters */

    dat = (float ****)MALLOC(i * sizeof(float ***));
    dat[0] = (float ***)MALLOC(i * j * sizeof(float **));
    dat[0][0] = (float **)MALLOC(i * j * k * sizeof(float *));
    dat[0][0][0] = (float *)MALLOC(i * j * k * l * sizeof(float));
    for (n = 1; n < i; n++) {
	dat[n] = dat[n - 1] + j;
    }
    for (n = 1, ne = i * j; n < ne; n++) {
	dat[0][n] = dat[0][n - 1] + k;
    }
    for (n = 1, ne = i * j * k; n < ne; n++) {
	dat[0][0][n] = dat[0][0][n - 1] + l;
    }
    return dat;
}

/*
 *------------------------------------------------------------------------
 *
 * Alloc_Free4 --
 *
 * 	This function frees an array allocated with Alloc_Arr4.
 *
 * Arguments:
 *	float ****dat	- address returned by Alloc_Arr4.
 *
 * Results:
 * 	None.
 *
 * Side effects:
 * 	Memory is freed.
 *
 *------------------------------------------------------------------------
 */

void Alloc_Free4(float ****dat)
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

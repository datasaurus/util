/*
 * alloc.c --
 *
 *	This file defines memory allocators.
 * 
 * Copyright (c) 2007, 2008 Gordon D. Carrie
 *
 * Licensed under the Open Software License version 3.0
 *
 * Please send feedback to user0@tkgeomap.org
 *
 * @(#) $Id: alloc.c,v 1.8 2008/10/31 16:30:43 gcarrie Exp $
 *
 **********************************************************************
 *
 */

#include <assert.h>
#include <stdlib.h>
#include <stdio.h>
#include "alloc.h"

/*
 * This counter records the number of times an allocator
 * has been called.  It helps to sort output for debugging.
 */

static unsigned c;

/*
 * Where to send diagnostic output
 */

#ifndef MEM_DEBUG_OUT
#define MEM_DEBUG_OUT 2
#endif

static FILE *out;

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
 * calloc_nrm --
 *
 *	This is a front end to calloc
 *
 * Arguments:
 *	size_t n	- number of items
 * 	size_t sz	- item size
 *
 * Results:
 * 	Memory is allocated with calloc.  Return value is return value of
 * 	calloc.
 *
 * Side effects:
 *	If the attempt to allocate memory fails, the process aborts.
 *
 *------------------------------------------------------------------------
 */

void *calloc_nrm(size_t n, size_t sz)
{
    void *m;

    m = calloc(n, sz);
    assert(m);
    return m;
}

/*
 *------------------------------------------------------------------------
 *
 * realloc_nrm --
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

void *realloc_nrm(void *m, size_t sz)
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
 * 	to stream out.
 *
 * Side effects:
 *	If the attempt to allocate memory fails, the process aborts.
 *
 *------------------------------------------------------------------------
 */

void *malloc_mdb(size_t sz, char *fl_nm, int ln)
{
    void *m;

    m = malloc(sz);
    assert(m);
    assert(out || (out = fdopen(MEM_DEBUG_OUT, "w")));
    fprintf(out, "%p (%09x) allocated at %s:%d\n", m, ++c, fl_nm, ln);
    return m;
}

/*
 *------------------------------------------------------------------------
 *
 * calloc_mdb --
 *
 * 	This allocator with debugging support allocates memory and prints
 * 	information.
 *
 * Arguments:
 * 	size_t n	- number of items
 * 	size_t sz	- item size
 * 	char *fl_nm	- string, assumed to be name of file where allocation
 *			  occurs.
 * 	int ln		- line number in fl_nm where allocation occurs.
 *
 * Results:
 * 	Memory is allocated with calloc.  Return value is return value of
 * 	calloc.  Information about where the allocation occurred is printed
 * 	to stream out.
 *
 * Side effects:
 *	If the attempt to allocate memory fails, the process aborts.
 *
 *------------------------------------------------------------------------
 */

void *calloc_mdb(size_t n, size_t sz, char *fl_nm, int ln)
{
    void *m;

    m = calloc(n, sz);
    assert(m);
    assert(out || (out = fdopen(MEM_DEBUG_OUT, "w")));
    fprintf(out, "%p (%09x) allocated at %s:%d\n", m, ++c, fl_nm, ln);
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
 * 	to stream out.
 *
 * Side effects:
 *	If the attempt to allocate memory fails, the process aborts.
 *
 *------------------------------------------------------------------------
 */

void *realloc_mdb(void *m, size_t sz, char *fl_nm, int ln)
{
    void *m2;

    m2 = realloc(m, sz);
    assert(m2);
    assert(out || (out = fdopen(MEM_DEBUG_OUT, "w")));
    if (m2 != m) {
	if (m) {
	    fprintf(out, "%p (%09x) freed by realloc at %s:%d\n",
		    m, ++c, fl_nm, ln);
	}
	fprintf(out, "%p (%09x) allocated by realloc at %s:%d\n",
		m2, ++c, fl_nm, ln);
    } else {
	fprintf(out, "%p (%09x) reallocated at %s:%d\n", m, ++c, fl_nm, ln);
    }
    return m2;
}

/*
 *------------------------------------------------------------------------
 *
 * free_mdb --
 *
 * 	This destructor with debugging support frees memory and prints
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
 * 	occurred is printed to stream out.
 *
 *------------------------------------------------------------------------
 */

void free_mdb(void *m, char *fl_nm, int ln)
{
    assert(out || (out = fdopen(MEM_DEBUG_OUT, "w")));
    fprintf(out, "%p (%09x) freed at %s:%d\n", m, ++c, fl_nm, ln);
    free(m);
}

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
 * @(#) $Id: alloc.c,v 1.2 2008/10/30 15:08:33 gcarrie Exp $
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

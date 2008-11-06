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
 * @(#) $Id: alloc.c,v 1.9 2008/11/06 17:09:42 gcarrie Exp $
 *
 **********************************************************************
 *
 */

#include <assert.h>
#include <stdlib.h>
#include <stdio.h>
#include "alloc.h"

static int init;
static void alloc_init(void);
static void clean(void);

/*
 * This counter records the number of times an allocator
 * has been called.  It helps to sort output for debugging.
 */

static unsigned c;

/*
 * Where to send diagnostic output
 */

static FILE *out;

/*
 *------------------------------------------------------------------------
 *
 * alloc_init --
 *
 *	Initialize this interface.
 *
 *------------------------------------------------------------------------
 */

void alloc_init(void)
{
    char *onm;
    int od;

    if (init) {
	return;
    }
    onm = getenv("MEM_DEBUG");
    if (onm) {
	if (sscanf(onm, "%d", &od) == 1) {
	    out = fdopen(od, "w");
	} else {
	    out = fopen(onm, "w");
	}
	assert(out);
	atexit(clean);
    }
    init = 1;
}
void clean()
{
    fclose(out);
}

/*
 *------------------------------------------------------------------------
 *
 * malloc_tkx --
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

void *malloc_tkx(size_t sz, char *fl_nm, int ln)
{
    void *m;

    if ( !init ) {
	alloc_init();
    }
    m = malloc(sz);
    assert(m);
    if (out)
	fprintf(out, "%p (%09x) allocated at %s:%d\n", m, ++c, fl_nm, ln);
    return m;
}

/*
 *------------------------------------------------------------------------
 *
 * calloc_tkx --
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

void *calloc_tkx(size_t n, size_t sz, char *fl_nm, int ln)
{
    void *m;

    if ( !init ) {
	alloc_init();
    }
    m = calloc(n, sz);
    assert(m);
    if (out) {
	fprintf(out, "%p (%09x) allocated at %s:%d\n", m, ++c, fl_nm, ln);
    }
    return m;
}

/*
 *------------------------------------------------------------------------
 *
 * realloc_tkx --
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

void *realloc_tkx(void *m, size_t sz, char *fl_nm, int ln)
{
    void *m2;

    if ( !init ) {
	alloc_init();
    }
    m2 = realloc(m, sz);
    assert(m2);
    if (out) {
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
    }
    return m2;
}

/*
 *------------------------------------------------------------------------
 *
 * free_tkx --
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

void free_tkx(void *m, char *fl_nm, int ln)
{
    if ( !init ) {
	alloc_init();
    }
    if (out) {
	fprintf(out, "%p (%09x) freed at %s:%d\n", m, ++c, fl_nm, ln);
    }
    free(m);
}

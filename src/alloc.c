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
 * @(#) $Id: alloc.c,v 1.11 2008/11/10 03:24:31 gcarrie Exp $
 *
 **********************************************************************
 *
 */

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <errno.h>
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

static FILE *diag_out;

/*
 * File and line at which to induce pretend memory failure
 */

static char *fail_fnm;
static int fail_line;

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
    char *s;
    int od;

    if (init) {
	return;
    }
    s = getenv("MEM_DEBUG");
    if (s) {
	if (sscanf(s, "%d", &od) == 1) {
	    diag_out = fdopen(od, "w");
	} else {
	    diag_out = fopen(s, "w");
	}
	if ( !diag_out ) {
	    perror("MEM_DEBUG set but unable to open diagnostic memory file");
	}
	atexit(clean);
    }
    s = getenv("MEM_FAIL");
    if (s) {
	fail_fnm = malloc(strlen(s) + 1);
	if (sscanf("%s:%d", fail_fnm, &fail_line) != 2) {
	    fprintf(stderr, "Could not get failure spec from %s\n", s);
	    free(fail_fnm);
	}
    }
    init = 1;
}
void clean()
{
    if (diag_out) {
	fclose(diag_out);
    }
    if (fail_fnm) {
	free(fail_fnm);
    }
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
 * 	char *fnm	- string, assumed to be name of file where allocation
 *			  occurs.
 * 	int ln		- line number in fnm where allocation occurs.
 *
 * Results:
 * 	Memory is allocated with malloc.  Return value is return value of
 * 	malloc.  Information about where the allocation occurred might be
 *	printed to stream diag_out.
 *
 *------------------------------------------------------------------------
 */

void *malloc_tkx(size_t sz, char *fnm, int ln)
{
    void *m;

    if ( !init ) {
	alloc_init();
    }
    m = malloc(sz);
    if (fail_fnm && (ln == fail_line) && strcmp(fail_fnm, fnm) == 0) {
	return NULL;
    }
    if (m && diag_out)
	fprintf(diag_out, "%p (%09x) allocated at %s:%d\n", m, ++c, fnm, ln);
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
 * 	char *fnm	- string, assumed to be name of file where allocation
 *			  occurs.
 * 	int ln		- line number in fnm where allocation occurs.
 *
 * Results:
 * 	Memory is allocated with calloc.  Return value is return value of
 * 	calloc.  Information about where the allocation occurred might be printed
 * 	to stream diag_out.
 *
 * Side effects:
 *	If the attempt to allocate memory fails, the process aborts.
 *
 *------------------------------------------------------------------------
 */

void *calloc_tkx(size_t n, size_t sz, char *fnm, int ln)
{
    void *m;

    if ( !init ) {
	alloc_init();
    }
    if (fail_fnm && (ln == fail_line) && strcmp(fail_fnm, fnm) == 0) {
	return NULL;
    }
    m = calloc(n, sz);
    if (m && diag_out) {
	fprintf(diag_out, "%p (%09x) allocated at %s:%d\n", m, ++c, fnm, ln);
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
 * 	char *fnm	- string, assumed to be name of file where allocation
 *			  occurs.
 * 	int ln		- line number in fnm where allocation occurs.
 *
 * Results:
 * 	Memory is reallocated with realloc.  Return value is return value of
 * 	realloc.  Information about where the reallocation occurred might be printed
 * 	to stream diag_out.
 *
 *------------------------------------------------------------------------
 */

void *realloc_tkx(void *m, size_t sz, char *fnm, int ln)
{
    void *m2;

    if ( !init ) {
	alloc_init();
    }
    if (fail_fnm && (ln == fail_line) && strcmp(fail_fnm, fnm) == 0) {
	return NULL;
    }
    m2 = realloc(m, sz);
    if (m2 && diag_out) {
	if (m2 != m) {
	    if (m) {
		fprintf(diag_out, "%p (%09x) freed by realloc at %s:%d\n",
			m, ++c, fnm, ln);
	    }
	    fprintf(diag_out, "%p (%09x) allocated by realloc at %s:%d\n",
		    m2, ++c, fnm, ln);
	} else {
	    fprintf(diag_out, "%p (%09x) reallocated at %s:%d\n", m, ++c, fnm, ln);
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
 * 	char *fnm	- string, assumed to be name of file where allocation
 *			  occurs.
 * 	int ln		- line number in fnm where allocation occurs.
 *
 * Results:
 * 	Memory is freed with free.  Information about where the reallocation
 * 	occurred might be printed to stream diag_out.
 *
 *------------------------------------------------------------------------
 */

void free_tkx(void *m, char *fnm, int ln)
{
    if ( !init ) {
	alloc_init();
    }
    if (diag_out) {
	fprintf(diag_out, "%p (%09x) freed at %s:%d\n", m, ++c, fnm, ln);
    }
    free(m);
}

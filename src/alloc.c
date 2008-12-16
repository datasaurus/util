/*
 - alloc.c --
 -	This file defines memory allocators.  See the alloc (3).
 -
   Copyright (c) 2007, 2008 Gordon D. Carrie
   Licensed under the Open Software License version 3.0
  
   Please send feedback to dev0@trekix.net
  
   $Id: alloc.c,v 1.18 2008/12/16 21:08:00 gcarrie Exp $
 */

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <errno.h>
#include "alloc.h"

static int init;
static void alloc_init(void);

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
 * Initialize this interface.
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
    }
    s = getenv("MEM_FAIL");
    if (s) {
	fail_fnm = malloc(strlen(s) + 1);
	if (sscanf(s, "%[^:]:%d", fail_fnm, &fail_line) != 2) {
	    fprintf(stderr, "Could not get failure spec from %s\n", s);
	    free(fail_fnm);
	}
    }
    init = 1;
}

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
    if (m && diag_out) {
	fprintf(diag_out, "%p (%09x) allocated at %s:%d\n", m, ++c, fnm, ln);
    }
    return m;
}

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

void alloc_clean()
{
    if (diag_out) {
	fclose(diag_out);
	diag_out = NULL;
    }
    if (fail_fnm) {
	free(fail_fnm);
	fail_fnm = NULL;
    }
}

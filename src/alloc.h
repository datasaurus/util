/*
 * alloc.c --
 *
 * 	This file declares memory allocators.
 * 
 * Copyright (c) 2007, 2008 Gordon D. Carrie
 *
 * Licensed under the Open Software License version 3.0
 *
 * Please send feedback to user0@tkgeomap.org
 *
 * @(#) $Id: alloc.h,v 1.10 2008/10/31 16:20:53 gcarrie Exp $
 *
 **********************************************************************
 *
 */

#ifndef ALLOC_H_
#define ALLOC_H_

#include <stdlib.h>

#ifdef __cplusplus
extern "C" {
#endif

#ifdef MEM_DEBUG
#define MALLOC(s) malloc_mdb((s), __FILE__, __LINE__)
#define CALLOC(n,s) calloc_mdb((n), (s), __FILE__, __LINE__)
#define REALLOC(x,s) realloc_mdb((x), (s), __FILE__, __LINE__)
#define FREE(x) free_mdb((x), __FILE__, __LINE__)
#else
#define MALLOC(s) malloc_nrm((s))
#define CALLOC(n,s) calloc_nrm((n), (s))
#define REALLOC(x,s) realloc_nrm((x),(s))
#define FREE(x) free((x))
#endif

void *malloc_nrm(size_t);
void *calloc_nrm(size_t, size_t);
void *realloc_nrm(void *, size_t);
void *malloc_mdb(size_t, char *, int);
void *calloc_mdb(size_t, size_t, char *, int);
void *realloc_mdb(void *, size_t, char *, int);
void free_mdb(void *, char *, int);

#ifdef __cplusplus
}
#endif

#endif

/*
 * alloc.c --
 *
 * 	This file declares memory allocators.
 * 
 * Copyright (c) 2007, 2008 Gordon D. Carrie
 *
 * Licensed under the Open Software License version 2.1
 *
 * Please send feedback to user0@tkgeomap.org
 *
 * @(#) $Id: alloc.h,v 1.2 2008/10/30 15:08:33 gcarrie Exp $
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
#define MALLOC(x) malloc_mdb(x, __FILE__, __LINE__)
#define REALLOC(x,s) realloc_mdb((x),(s), __FILE__, __LINE__)
#define FREE(x) free_mdb((x), __FILE__, __LINE__)
#else
#define MALLOC(x) malloc_nrm((x))
#define REALLOC(x,s) realloc_nrm((x),(s))
#define FREE(x) free((x))
#endif

void *malloc_nrm(size_t sz);
void *realloc_mdb(void *m, size_t sz);
void *malloc_mdb(size_t sz, char *fl_nm, int ln);
void *realloc_mdb(void *m, size_t sz, char *fl_nm, int ln);
void free_mdb(void *m, char *fl_nm, int ln);

#ifdef __cplusplus
}
#endif

#endif

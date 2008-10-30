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
 * @(#) $Id: alloc.h,v 1.1 2008/09/01 17:55:10 tkgeomap Exp $
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
float ***Alloc_Arr3(size_t i, size_t j, size_t k);
void Alloc_Free3(float ***d);
float ****Alloc_Arr4(size_t i, size_t j, size_t k, size_t l);
void Alloc_Free4(float ****d);
    
#ifdef __cplusplus
}
#endif

#endif

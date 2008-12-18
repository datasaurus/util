/*
 - alloc.c --
 - 	This header declares memory allocators.  See alloc (3).
 - 
   Copyright (c) 2007, 2008 Gordon D. Carrie
   Licensed under the Open Software License version 3.0
  
   Please send feedback to dev0@trekix.net
  
   $Id: alloc.h,v 1.14 2008/12/02 17:19:39 gcarrie Exp $
 */

#ifndef ALLOC_H_
#define ALLOC_H_

#include <stdlib.h>

#ifdef __cplusplus
extern "C" {
#endif

#define MALLOC(s) malloc_tkx((s), __FILE__, __LINE__)
#define CALLOC(n,s) calloc_tkx((n), (s), __FILE__, __LINE__)
#define REALLOC(x,s) realloc_tkx((x), (s), __FILE__, __LINE__)
#define FREE(x) free_tkx((x), __FILE__, __LINE__)

void *malloc_tkx(size_t, char *, int);
void *calloc_tkx(size_t, size_t, char *, int);
void *realloc_tkx(void *, size_t, char *, int);
void free_tkx(void *, char *, int);

#ifdef __cplusplus
}
#endif

#endif

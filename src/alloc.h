/*
 - alloc.h --
 - 	This header declares memory allocators.  See alloc (3).
 - 
   Copyright (c) 2007, 2008 Gordon D. Carrie
   Licensed under the Open Software License version 3.0
  
   Please send feedback to dev0@trekix.net
  
   $Revision: 1.18 $ $Date: 2008/12/19 18:05:03 $
 */

#ifndef ALLOC_H_
#define ALLOC_H_

#include <stdlib.h>

#define MALLOC(s) malloc_tkx((s), __FILE__, __LINE__)
#define CALLOC(n,s) calloc_tkx((n), (s), __FILE__, __LINE__)
#define REALLOC(x,s) realloc_tkx((x), (s), __FILE__, __LINE__)
#define FREE(x) free_tkx((x), __FILE__, __LINE__)

void *malloc_tkx(size_t, char *, int);
void *calloc_tkx(size_t, size_t, char *, int);
void *realloc_tkx(void *, size_t, char *, int);
void free_tkx(void *, char *, int);

#endif

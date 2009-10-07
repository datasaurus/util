/*
   -	alloc.h --
   -		This header declares memory allocators.  See alloc (3).
   -	
   .	Copyright (c) 2007 Gordon D. Carrie
   .	All rights reserved.
   .
   .	Please send feedback to dev0@trekix.net
   .
   .	$Revision: 1.21 $ $Date: 2009/10/01 22:15:22 $
 */

#ifndef ALLOC_H_
#define ALLOC_H_

#include <stdlib.h>

#define MALLOC(s) Malloc_Tkx((s), __FILE__, __LINE__)
#define CALLOC(n,s) Calloc_Tkx((n), (s), __FILE__, __LINE__)
#define REALLOC(x,s) ReAlloc_Tkx((x), (s), __FILE__, __LINE__)
#define FREE(x) Free_Tkx((x), __FILE__, __LINE__)

void *Malloc_Tkx(size_t, char *, int);
void *Calloc_Tkx(size_t, size_t, char *, int);
void *ReAlloc_Tkx(void *, size_t, char *, int);
void Free_Tkx(void *, char *, int);

#endif

/*
   -	alloc.h --
   -		This header declares memory allocators.  See alloc (3).
   -	
   .	Copyright (c) 2007 Gordon D. Carrie
   .	All rights reserved.
   .
   .	Please send feedback to dev0@trekix.net
   .
   .	$Revision: 1.22 $ $Date: 2009/10/07 17:06:47 $
 */

#ifndef ALLOC_H_
#define ALLOC_H_

#include <stdlib.h>

#define MALLOC(s) Tkx_Malloc((s), __FILE__, __LINE__)
#define CALLOC(n,s) Tkx_Calloc((n), (s), __FILE__, __LINE__)
#define REALLOC(x,s) Tkx_ReAlloc((x), (s), __FILE__, __LINE__)
#define FREE(x) Tkx_Free((x), __FILE__, __LINE__)

void *Tkx_Malloc(size_t, char *, int);
void *Tkx_Calloc(size_t, size_t, char *, int);
void *Tkx_ReAlloc(void *, size_t, char *, int);
void Tkx_Free(void *, char *, int);

#endif

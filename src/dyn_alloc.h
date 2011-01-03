/*
   -	dyn_alloc.h --
   -		This header declares dynamic memory allocators.
   -	
   .	Copyright (c) 2010 Gordon D. Carrie
   .	All rights reserved.
   .
   .	Please send feedback to dev0@trekix.net
   .
   .	$Revision: 1.1 $ $Date: 2011/01/03 20:29:52 $
 */

#ifndef DYN_ALLOC_H_
#define DYN_ALLOC_H_

#include <stdlib.h>

void *dyn_alloc(void *, size_t *, size_t, void *, size_t, size_t);

#endif

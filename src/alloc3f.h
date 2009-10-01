/*
   -	alloc3f.h --
   -		This header declares functions that
   -		allocate 3-dimensional arrays of
   -		floating point values.  See alloc3f (3).
   -	
   .	Copyright (c) 2008 Gordon D. Carrie
   .	All rights reserved
   .
   .	Please send feedback to dev0@trekix.net
   .
   .	$Revision: 1.5 $ $Date: 2009/09/25 21:33:13 $
 */

#ifndef ALLOC_3F_H_
#define ALLOC_3F_H_

float ***calloc3f(long, long, long);
void free3f(float ***);

#endif

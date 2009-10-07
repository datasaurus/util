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
   .	$Revision: 1.6 $ $Date: 2009/10/01 22:15:22 $
 */

#ifndef ALLOC_3F_H_
#define ALLOC_3F_H_

float ***Calloc3F(long, long, long);
void Free3F(float ***);

#endif

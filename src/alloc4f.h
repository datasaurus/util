/*
   -	alloc4f.h --
   -		This header declares functions that
   -		allocate 4-dimensional arrays of
   -		floating point values.  See alloc4f (3).
   -	
   .	Copyright (c) 2008 Gordon D. Carrie
   .	All rights reserved
   .
   .	Please send feedback to dev0@trekix.net
   .
   .	$Revision: 1.6 $ $Date: 2009/10/01 22:15:22 $
 */

#ifndef ALLOC_4F_H_
#define ALLOC_4F_H_

float ****Calloc4F(long, long, long, long);
void Free4F(float ****);

#endif

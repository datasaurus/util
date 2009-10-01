/*
   -	alloc2f.h --
   -		This header declares functions that
   -		allocate 2-dimensional arrays of floating
   -		point values.  See alloc2f (3).
   -	
   .	Copyright (c) 2008 Gordon D. Carrie
   .	All rights reserved
   .
   .	Please send feedback to dev0@trekix.net
   .
   .	$Revision: 1.5 $ $Date: 2009/09/25 21:33:13 $
 */

#ifndef ALLOC_2F_H_
#define ALLOC_2F_H_

float **calloc2f(long, long);
void free2f(float **);

#endif

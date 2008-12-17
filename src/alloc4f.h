/*
 - alloc4f.h --
 -	This header declares functions that allocate 4-dimensional
 -	arrays of floating point values.  See alloc4f (3).
 - 
   Copyright (c) 2008 Gordon D. Carrie
   Licensed under the Open Software License version 3.0
  
   Please send feedback to dev0@trekix.net
  
   $Revision$ $Date$
 */

#ifndef ALLOC_4F_H_
#define ALLOC_4F_H_

float ****calloc4f(long, long, long, long);
void free4f(float ****);

#endif

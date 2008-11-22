/*
 - alloc2f.h --
 -	This header declares functions that allocate 2-dimensional
 -	arrays of floating point values.  See alloc2f (3).
 - 
   Copyright (c) 2008 Gordon D. Carrie
   Licensed under the Open Software License version 3.0
  
   Please send feedback to user0@tkgeomap.org
  
   $Id: alloc2f.h,v 1.1 2008/11/22 03:37:38 gcarrie Exp $
 */

#ifndef ALLOC_2F_H_
#define ALLOC_2F_H_

float **calloc2f(long, long);
void free2f(float **);

#endif

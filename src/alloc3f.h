/*
 * alloc3f.h --
 *
 *	This header declares functions that allocate 3-dimensional
 *	arrays of floating point values.  See alloc3f (3).
 * 
 * Copyright (c) 2008 Gordon D. Carrie
 *
 * Licensed under the Open Software License version 3.0
 *
 * Please send feedback to user0@tkgeomap.org
 *
 * $Id: $
 *
 */

#ifndef ALLOC_3F_H_
#define ALLOC_3F_H_

float ***calloc3f(long, long, long);
void free3f(float ***);

#endif

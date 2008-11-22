/*
 * alloc2f.h --
 *
 *	This header declares functions that allocate 2-dimensional
 *	arrays of floating point values.  See alloc2f (3).
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

#ifndef ALLOC_2F_H_
#define ALLOC_2F_H_

float **calloc2f(long, long);
void free2f(float **);

#endif

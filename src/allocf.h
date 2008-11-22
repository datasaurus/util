/*
 * allocf.h --
 *
 *	This header declares functions that allocate multi-dimensional
 *	arrays of floating point values.
 * 
 * Copyright (c) 2008 Gordon D. Carrie
 *
 * Licensed under the Open Software License version 3.0
 *
 * Please send feedback to user0@tkgeomap.org
 *
 * $Id: allocf.h,v 1.5 2008/11/17 04:49:21 gcarrie Exp $
 *
 */

#ifndef ALLOC_F_H_
#define ALLOC_F_H_

#ifdef __cplusplus
extern "C" {
#endif

#include <stddef.h>

float **mallocf2(long j, long i);
void freef2(float **d);
float ***mallocf3(long k, long j, long i);
void freef3(float ***d);
float ****mallocf4(long l, long k, long j, long i);
void freef4(float ****d);

#ifdef __cplusplus
}
#endif

#endif

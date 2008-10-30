/*
 * allocf.h --
 *
 *	This header declares functions that allocate multi-dimensional
 *	arrays of floating point values.
 * 
 * Copyright (c) 2008 Gordon D. Carrie
 *
 * Licensed under the Open Software License version 2.1
 *
 * Please send feedback to user0@tkgeomap.org
 *
 * $Id$
 *
 */

#ifndef ALLOC_F_H_
#define ALLOC_F_H_

#ifdef __cplusplus
extern "C" {
#endif

#include <stddef.h>
#include "alloc.h"

float ***Alloc_Arr3(size_t i, size_t j, size_t k);
void Alloc_Free3(float ***d);
float ****Alloc_Arr4(size_t i, size_t j, size_t k, size_t l);
void Alloc_Free4(float ****d);

#ifdef __cplusplus
}
#endif

#endif

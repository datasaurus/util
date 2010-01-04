/*
   -	str.h --
   -		This header declares string manipulation
   -		functions.  See str (3).
   -	
   .	Copyright (c) 2009 Gordon D. Carrie
   .	All rights reserved
   .
   .	Please send feedback to dev0@trekix.net
   .
   .	$Revision: 1.9 $ $Date: 2010/01/04 20:27:19 $
 */

#ifndef STR_H_
#define STR_H_

#include <stdlib.h>

char *Str_Esc(char *s);
char ** Str_Words(char *, char **, int *);
char * Str_Append(char *, size_t *, size_t *, char *, size_t);
int Str_GetLn(FILE *, char, char **, int *);
    
#endif

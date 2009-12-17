/*
 -	bhead --
 -		Command line utility prints a given number of bytes from a file.
 -		See bhead (1).
 -
 .	Copyright (c) 2009 Gordon D. Carrie
 .	All rights reserved.
 .
 .	Please send feedback to dev0@trekix.net
 .
 .	$Revision: $ $Date: $
 */

#include <stdlib.h>
#include <stdio.h>

int main(int argc, char *argv[])
{
    unsigned long n;
    int i;

    if (argc != 2 || (sscanf(argv[1], "%lu", &n) != 1)) {
	fprintf(stderr, "Usage: %s n\n", argv[0]);
	exit(1);
    }
    while (n-- > 0 && ((i = getchar()) != EOF) && (putchar(i) != EOF))
	continue;
    return 0;
}

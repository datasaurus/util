#!/bin/sh
#
#- findleaks.sh --
#-	This script tests the src/findleaks script.
#-
# Copyright (c) 2008 Gordon D. Carrie
# Licensed under the Open Software License version 3.0
#
# Please send feedback to dev0@trekix.net
#
# $Id: $
#
########################################################################

echo "
findleaks.sh --

This script tests the src/findleaks application.  See findleaks (1) for
information on findleaks.

Copyright (c) 2008 Gordon D. Carrie
Licensed under the Open Software License version 3.0

--------------------------------------------------------------------------------
"

FINDLEAKS=src/findleaks

# Set RM to : in environment to save temporary files.
RM=${RM:-'rm -f'}

CC="cc"
CFLAGS="-g -Wall -Wmissing-prototypes"

echo "test1: evaluate output from a normal process."

status=success
$FINDLEAKS > test1.out << END
0x00000001 (000000001) allocated at makebelieve.c:10
0x00000001 (000000002) freed at makebelieve.c:14
0x00000002 (000000003) allocated at makebelieve.c:16
0x00000002 (000000004) freed at makebelieve.c:20
END
case $? in
    0)
	echo "findleaks reported leaks when there were not any."
	status=fail
	;;
    1)
	echo "findleaks reported no leaks."
	;;
    2)
	echo "findleaks did not see input."
	status=fail
	;;
esac
cat /dev/null > empty
if diff test1.out empty
then
    echo "findleaks produced correct output"
else
    echo "findleaks produced incorrect output"
    status=fail
fi
if [ $status = "success" ]
then
    echo "test1 successful"
else
    echo "test1 failed"
fi
$RM test1.out empty
echo "Done with test1

--------------------------------------------------------------------------------
"

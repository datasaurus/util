#!/bin/sh
#
#- chkalloc.sh --
#-	This test application tests src/chkalloc.  It checks
#-	chkalloc's ability to correctly process text files with
#-	various diagnostic outputs.
#-
# Copyright (c) 2011, Gordon D. Carrie. All rights reserved.
# 
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# 
#     * Redistributions of source code must retain the above copyright
#     notice, this list of conditions and the following disclaimer.
#     * Redistributions in binary form must reproduce the above copyright
#     notice, this list of conditions and the following disclaimer in the
#     documentation and/or other materials provided with the distribution.
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
# A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
# HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
# SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
# TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
# PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
# LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
# NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
# Please send feedback to dev0@trekix.net
#
# $Revision: 1.15 $ $Date: 2011/11/28 16:11:23 $
#
########################################################################

echo "
chkalloc.sh --

This test application tests src/chkalloc.  See chkalloc (1) for
information on chkalloc.

To save temporary files, set RM to : in environment before running this
application.

Copyright (c) 2011 Gordon D. Carrie
All rights reserved
See $0 for distribution terms

################################################################################
"

# Set RM to : in environment to save temporary files.
RM=${RM:-'rm -f'}

CC="cc -std=c99"
CFLAGS="-g -Wall -Wmissing-prototypes"

CHKALLOC=src/chkalloc
if ! test -x $CHKALLOC
then
    echo "No executable named $CHKALLOC"
    exit 1
fi

echo "test1: evaluate output from a normal process."
result1=success
correct=0
cat /dev/null > correct1.out
$CHKALLOC > test1.out << END
0x00000001 (000000001) allocated at makebelieve.c:10
0x00000001 (000000002) freed at makebelieve.c:14
0x00000002 (000000003) allocated at makebelieve.c:16
0x00000002 (000000004) freed at makebelieve.c:20
END
if [ $? -eq $correct ]
then
    echo "chkalloc gave correct return value ($correct)"
else
    echo "chkalloc gave wrong return value ($? instead of $correct)"
    result1=fail
fi
if diff test1.out correct1.out
then
    echo "chkalloc output was correct."
else
    echo "chkalloc output was wrong."
    result1=fail
fi
$RM test1.out correct1.out
echo "test1 result = $result1
Done with test1

################################################################################
"

echo "test2: evaluate output from a process that leaks memory."
result2=success
correct=1
$CHKALLOC > test2.out << END
0x00000001 (000000001) allocated at makebelieve.c:10
0x00000001 (000000002) freed at makebelieve.c:14
0x00000002 (000000003) allocated at makebelieve.c:16
END
if [ $? -eq $correct ]
then
    echo "chkalloc gave correct return value ($correct)"
else
    echo "chkalloc gave wrong return value ($? instead of $correct)"
    result2=fail
fi
if egrep -q "Leak at [0-9x]+" test2.out
then
    echo "chkalloc output was correct."
else
    echo "chkalloc output was wrong."
    result2=fail
fi
$RM test2.out
echo "test2 result = $result2
Done with test2

################################################################################
"

echo "test3: check chkalloc on no input"

result3=success
correct=0
cat /dev/null > correct3.out
: | $CHKALLOC > test3.out 2>&1
if [ $? -eq $correct ]
then
    echo "chkalloc gave correct return value ($correct)"
else
    echo "chkalloc gave wrong return value ($? instead of $correct)"
    result3=fail
fi
if diff test3.out correct3.out
then
    echo "chkalloc output was correct."
else
    echo "chkalloc output was wrong."
    result3=fail
fi
$RM test3.out correct3.out
echo "test3 result = $result3
Done with test3

################################################################################
"

echo "test4: check chkalloc on no input with CHKALLOC_WARN set"

result4=success
correct=2
echo "Warning chkalloc did not receive input." > correct4.out
export CHKALLOC_WARN=1
: | $CHKALLOC > test4.out 2>&1
if [ $? -eq $correct ]
then
    echo "chkalloc gave correct return value ($correct)"
else
    echo "chkalloc gave wrong return value ($? instead of $correct)"
    result4=fail
fi
unset CHKALLOC_WARN
if diff test4.out correct4.out
then
    echo "chkalloc output was correct."
else
    echo "chkalloc output was wrong."
    result4=fail
fi
$RM test4.out correct4.out
echo "test4 result = $result4
Done with test4

################################################################################
"

echo "Summary:
$0 test1 result = $result1
$0 test2 result = $result2
$0 test3 result = $result3
$0 test4 result = $result4
"

echo "$0 all done.

################################################################################
################################################################################
"

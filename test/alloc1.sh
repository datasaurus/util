#!/bin/sh
#
# This script exercises alloc1.c.
#
# $Id: alloc1.sh,v 1.1 2008/10/31 21:04:41 gcarrie Exp $

EXEC=alloc1
FINDLEAKS=src/findleaks
OUT=alloc1.out
RM='rm -f'

$RM $OUT

echo test1: building and running alloc1
cc -Isrc -o $EXEC src/alloc.c alloc1.c
$EXEC
echo Done with test1
echo ""
$RM $EXEC

echo test2: building and running alloc1 with memory trace.
echo An account of allocations and calls to free should appear on terminal
export MEM_DEBUG=2
cc -Isrc -o alloc1 src/alloc.c alloc1.c
$EXEC
echo Done with test2
echo ""
$RM $EXEC

echo test3: building and running alloc1 with memory trace.
echo An account of allocations and calls to free should appear in $OUT
echo YOU SHOULD LOOK AT $OUT
echo Contents of $OUT should resemble output from test2
export MEM_DEBUG=$OUT
cc -Isrc -o alloc1 src/alloc.c alloc1.c
$EXEC
echo Done with test3
echo ""
$RM $EXEC

echo test4: building and running alloc1.
echo Sending memory trace to findleaks, which should not find anything.
export MEM_DEBUG=2
cc -Isrc -o alloc1 src/alloc.c alloc1.c
$EXEC 2>&1 | $FINDLEAKS
echo Done with test4
echo ""
$RM $EXEC

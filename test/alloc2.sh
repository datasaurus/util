#!/bin/sh
#
# This script exercises alloc2.c.
#
# $Id: alloc2.sh,v 1.1 2008/10/31 21:05:37 gcarrie Exp $

EXEC=alloc2
FINDLEAKS=src/findleaks
OUT=alloc2.out
RM='rm -f'

$RM $OUT

echo test1: building and running alloc2
cc -Isrc -o $EXEC src/alloc.c alloc2.c
$EXEC
echo Done with test1
echo ""
$RM $EXEC

echo test2: building and running alloc2 with memory trace.
echo An account of allocations and calls to free should appear on terminal
export MEM_DEBUG=2
cc -Isrc -o alloc2 src/alloc.c alloc2.c
$EXEC
echo Done with test2
echo ""
$RM $EXEC

echo test3: building and running alloc2.
echo Sending memory trace to findleaks, which should report a leak.
export MEM_DEBUG=2
cc -Isrc -o alloc2 src/alloc.c alloc2.c
$EXEC 2>&1 | $FINDLEAKS
echo Done with test3
echo ""
$RM $EXEC

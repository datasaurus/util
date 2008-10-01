#!/bin/sh

# This script tests the hash table interface in visky3.
#
# $Id: hash.sh,v 1.12 2008/09/30 20:15:41 tkgeomap Exp $ || exit 1

echo ''
echo '------------------------------- hash1 ----------------------------------'
echo ''
./hash1.sh || exit 1
echo ''
echo '------------------------------- hash2 ----------------------------------'
echo ''
./hash2.sh || exit 1
echo ''
echo '------------------------------- hash3 ----------------------------------'
echo ''
./hash3.sh || exit 1
echo ''
echo '------------------------------- hash4 ----------------------------------'
echo ''
./hash4.sh || exit 1

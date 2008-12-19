#!/bin/sh

# This script tests the hash table interface in visky3.
#
# $Revision$ $Date$

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

#!/bin/sh
#
#- hash.sh --
#-	This script tests the hash table interface in visky3.
#-
# Copyright (c) 2008 Gordon D. Carrie
# Licensed under the Open Software License version 3.0
#
# $Revision: 1.3 $ $Date: 2008/12/19 18:05:53 $

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

#!/bin/sh

#######################################################
#
# Quick build script for traf
#
# Hideyuki Kawabata (C) 2018
#
# This file is a part of "traf".
#
#######################################################

if [ -d "./build" ] ; then
    echo "$0: ./build exists."
    exit 1
elif [ -d "./misc" ] && [ -d "./src" ] ; then
    echo "$0: Building build/traf ..."
    tar zxfv ./misc/prooftree-0.13.tar.gz
    if [ $? -ne 0 ] ; then
	echo "$0: tar could not run correctly."
	exit 1
    fi
    mv prooftree-0.13 build
    cd build
    cp ../src/* .
    patch -p1 < prooftree-to-traf.patch
    if [ $? -ne 0 ] ; then
	echo "$0: patch could not run correctly."
	exit 1
    fi
    ./configure
    if [ $? -ne 0 ] ; then
	echo "$0: configure did not finish."
	exit 1
    fi
    make
    echo "Done."
else
    echo "Run this command in the top directory."
fi

#!/bin/bash

export PATH="$PATH:$PWD/node_modules/.bin:/usr/local/bin"

COMPILE="./test"

if [ ! -d $COMPILE ]; then
	mkdir -p $COMPILE
fi

rm -rf $COMPILE/*

# prevents weird error...
# https://groups.google.com/forum/?fromgroups=#!topic/nodejs/jeec5pAqhps
ulimit -n 10000

echo -n "Compiling CoffeeScript for app... "
time coffee --output $COMPILE --compile ./src-test

if [ $? -eq "0" ]; then
	echo "Done."
else
	echo "Error: failed to compile CoffeeScript"
fi

time mocha

if [ $? -eq "0" ]; then
	echo "Done."
else
	echo "Error: failed to run tests"
fi

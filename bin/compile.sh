#!/bin/bash

export PATH="$PWD/node_modules/.bin:/usr/local/bin:$PATH"

# prevents weird error...
# https://groups.google.com/forum/?fromgroups=#!topic/nodejs/jeec5pAqhps
ulimit -n 10000

echo "Compiling CoffeeScript... "
time coffee --output . --compile .

if [ ! $? -eq "0" ]; then
	echo "Error: failed to compile CoffeeScript"
	exit
fi

echo "Running unit tests..."
time mocha

if [ ! $? -eq "0" ]; then
	echo "Error: failed to run tests"
	exit
fi

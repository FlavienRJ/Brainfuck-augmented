#!/bin/bash
DIR="build/"
BUILD_FILE="build.sh"
if [ ! "$(ls -A $DIR)" ]; then
    source build.sh
fi
./build/taltech-lang test/test1.tf
#!/bin/bash
cd src && flex taltech-lang.l &&\
bison -d taltech-lang.y &&\
gcc *.c -o ../build/taltech-lang && cd .. &&\
chmod +x build/taltech-lang
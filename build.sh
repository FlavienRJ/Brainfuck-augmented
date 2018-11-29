#!/bin/bash
cd src && flex brainfuck-augmented.l &&\
bison -d brainfuck-augmented.y &&\
gcc -Wall *.c -o ../build/brainfuck-augmented && cd .. &&\
chmod +x build/brainfuck-augmented
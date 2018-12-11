#!/bin/bash
cd src && flex brainfuck-augmented.l &&\
bison -d brainfuck-augmented.y &&\
gcc -Wall lex.yy.c brainfuck-augmented.tab.c -o ../build/brainfuck-augmented && cd .. &&\
cd build && chmod +x brainfuck-augmented

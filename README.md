# project analysis of programming language
Project for the course *"Analysis of programming language"*, Taltech university :ee: autumn 2018
***By Theresa Kull*** :de: ***and Flavien Ronteix--Jacquet de Mehun*** :fr:

### Brainfuck
https://esolangs.org/wiki/Truth-machine

**Why you should work with Brainfuck?**
- Turing-completeness language (https://en.wikipedia.org/wiki/Turing_completeness) then it can be used to simulate any Turing machine : very powerful
- Help to understand Turing machine

- [Wikipedia link](https://en.wikipedia.org/wiki/Brainfuck)
- [Esolangs link](https://en.wikipedia.org/wiki/Brainfuck)
- [99 bottles of beer program](http://99-bottles-of-beer.net/language-brainfuck-2542.html)
- [Examples of programs in bf](http://rosettacode.org/wiki/Category:Brainf***)

## Description of the improvements for the language

extension : *.bfa

### Brainfuck augmented
- **\#** : comment line [New]
- **\>** : move pointer to the right cell 
- **\<** : move pointer to the left cell 
- **\+** : increase cell's value
- **\-** : decrease cell's value
- **\.** : Output cell pointed in stdout
- **\,** : Read user input and write it on pointed cell 
- **\[** : loop (if cell's value is different 0 execute loop)
- **\]** : end block while
- **\:A** : start new procedure A [NEW]
- **\;** : end procedure [NEW]
- **\$** : clean tape [NEW]

## Use program

On UNIX system !

### Requirements
- Flex
- Bison
- Gcc

### Build

Run `./build.sh` to *build* the program (use flex).
Generate the program (brainfuck-augmented) in build folder

### Run

./build/brainfuck-augmented : run a simple interpreter by default

**Arguments**
- **-i** : run an interpreter in interactive console
- **-i filename.bfa** : execute the brainfuck program *filename.bfa*
- **-d** : enable debug informations
- **-v** : enable visualization tool of the tape
- **-c filename.bfa** : translate the brainfuck program *filename.bfa* in C [Not working now]
- **-o filename.bfa** : compile the brainfuck program *filename.bfa* [Not working now]
- **-a nbArg arg1 arg2 ... argN** : fill the tape with the *nbArg*

### Interpreter

enter your command, you can have new lines and comments to make your input more readable. To execute, double new line.

### Examples

Brainfuck program examples are in *test* folder

- **beers-song.bfa** : 99 bottles of beer test program (99-bottles-of-beer.net)
- **condition.bfa** : a condition in brainfuck print 0 if x and y different and 1 if equal
- **hello-world.bfa** : traditionnal hello world! program
- **little-sort.bfa** : a sorting program. enter input, 0 to end input and get order value.
- **mandelbrot.bfa** : (https://github.com/pablojorge/brainfuck/tree/master/programs) compute and print mandelbrot set in brainfuck
- **multiply.bfa** : a simple multiplication program. enter x and y and print x*y
- **test-proc.bfa** : a program to test procedures

# project analysis of programming language
Project for the course "Analysis of programming language" at Taltech university 2018
### By Theresa Kull and Flavien Ronteix--Jacquet de Mehun

## Ideas

- (Almost) full functional language
- We can get some ideas from other language : a list (non-exhaustive) with hello-world example https://github.com/leachim6/hello-world
- function of iterator point on the value of the last result

### Parse an existing language
- Real language : LISP or F\#
- Otherwise : Brainfuck or one of them https://esolangs.org/wiki/Truth-machine

Implementation of  
- an interpreter
- a compiler (translate code to C and compile it)
- visualization tool step by step of what's happen on the tape to help debuging
- debug mode to output the nodes, the size of used cells in tape,...

Why ?
- Fully Turing-complete
- Help to understand Turing machine

- [Wikipedia link](https://en.wikipedia.org/wiki/Brainfuck)
- [Esolangs link](https://en.wikipedia.org/wiki/Brainfuck)
- [Bublesort in bf](http://99-bottles-of-beer.net/language-brainfuck-2542.html)
- [Examples of programs in bf](http://rosettacode.org/wiki/Category:Brainf***)

## Description of the language

extension : *.bfa

### Brainfuck augmented
- \# : comment line
- \> : move pointer to the right (ptr++)
- \< : move pointer to the left (ptr--)
- \+ : increase value pointed (*ptr++)
- \- : decrease value pointed (*ptr--)
- \. : Output cell pointed in stdout (putchar(*ptr))
- \, : Read use input and put on pointed cell (*ptr = getchar())
- \[ : block while (while (*ptr){)
- \] : end block while (})
- \:A : start new procedure A (void A(ptr){)
- \; : end procedure
- Why not function with a new tape. The last value of this tape is returned at the end of function.
- Builtin functions like convert number to ascii number, add 57 to convert to ascii,...
- Arguments for the program. Ex ./brainfuck -i test.tf 1 2 3 4 5 will write 1 2 3 4 5 on the first 5 cells of the tape

## What we need to implement
- [ ] procedure
- [ ] loops
- [ ] conditional statements
- [ ] input
- [ ] output
- [ ] bubble sort or any other example programm
- [ ] comment

## Todo list
- [X] Write a parser
- [X] Write an interpreter
- [ ] Write a compiler
- [ ] Visualization tool
- [ ] Add builtins functions like clear_tape, goto,...
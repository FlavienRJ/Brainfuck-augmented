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

Why ?
- Fully Turing-complete
- Help to understand Turing machine

- [Wikipedia link](https://en.wikipedia.org/wiki/Brainfuck)
- [Esolangs link](https://en.wikipedia.org/wiki/Brainfuck)
- [Bublesort in bf](http://99-bottles-of-beer.net/language-brainfuck-2542.html)

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

##


## What we need to implement
- [ ] procedure
- [ ] loops
- [ ] conditional statements
- [ ] input
- [ ] output
<<<<<<< HEAD
=======
- [ ] datatype int and float
- [ ] array
<<<<<<< HEAD
- [ ] bubble sort or any other example programm
=======
>>>>>>> 6516d9e10403f938e4ecefe00a6996c1ad4d5044
- [ ] comment

## Todo list
- [ ] Write a parser
- [ ] Write an interpreter
- [ ] Write a compiler
<<<<<<< HEAD
- [ ] Visualization tool
=======
>>>>>>> 1200e6c5cf61d133c7b8a6b85403cb660ef95bf5
>>>>>>> 6516d9e10403f938e4ecefe00a6996c1ad4d5044

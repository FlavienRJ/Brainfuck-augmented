%{
#include "brainfuck-augmented.h"
#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <string.h>
extern int yylex(void);
extern int yylineno;
extern FILE *yyin;
void yyerror(const char *s);

int visualisation = 0;
int interpreter = 1; 
int debug = 0;
int file = 0;

int TAPE[TAPE_SIZE] = {0};
int* HEAD;

int IC = 0; //Instruction Counter

t_instruction PROGRAM[PROGRAM_SIZE];
int STACK[STACK_SIZE];
int SP = 0; //Stack pointer
%}

%union{
	char procname;
}

%error-verbose
%token MRIGHT MLEFT ADD MINUS OUTPUT INPUT 
%token LOOP END_LOOP PROCEDURE END_PROCEDURE
%token <procname> PROCNAME

//Rules
%%
program : stmts { printf("End statement\n"); endprog(); }
		;
stmts : stmt  
	| stmts stmt  
	;
stmt : MRIGHT { printf("[%d] go right\n", IC); mright(); IC++; }
	| MLEFT { printf("[%d] go left\n", IC); mleft(); IC++; }
	| ADD { printf("[%d] add\n", IC); cadd(); IC++; }
	| MINUS { printf("[%d] decrease\n", IC); cminus(); IC++; }
	| OUTPUT { printf("[%d] print\n", IC); coutput(); IC++; }
	| INPUT { printf("[%d] read\n", IC); cinput(); IC++; }
	| LOOP { printf("[%d] loop\n", IC); mloop(); IC++; }
	| END_LOOP { printf("[%d] end loop\n", IC); mloopend(); IC++; }
	| PROCEDURE PROCNAME stmts END_PROCEDURE { printf("[%d] new procedure %c\n", IC, $2); IC++; }
	| PROCNAME { printf("[%d] call procedure %c\n", IC, $1); IC++; }
	;
%%

void yyerror(const char *s){
	printf("ERROR: %s at line %d\n", s, yylineno); 
}

int main(int argc, char **argv)
{
	int i;
	char filename[30];
	
	for (i=1; i < argc; i++)
	{
		//interpreter
		if (strcmp(argv[i], "-i") == 0)
		{
			if (argv[i+1] != NULL)
			{
				strcpy(filename, argv[i+1]);
				file = 1;
			}
		}
		//compiler
		else if (!strcmp(argv[i], "-c"))
		{
			interpreter = 0;
			if (argv[i+1] != NULL)
			{
				strcpy(filename, argv[i+1]);
				file = 1;
			}
			else
			{
				printf("No source file to compile!\n");
				return -1;
			}
		}
		//visualisation
		else if (!strcmp(argv[i], "-v"))
		{
			visualisation = 1;
		}
		//debug
		else if (!strcmp(argv[i], "-d"))
		{
			debug = 1;
		}
		else
		{
			continue;
		}
	}
	if (file)
	{
		//problem with name with - on
		yyin = fopen(filename, "r");
		if(yyin == NULL)
		{
			printf("Error opening %s", filename);
			return -1;
		}
	}
	printf("A\n");
	init();
	yyparse();
	fclose(yyin);
	return 0;
}

void init()
{
	HEAD = &TAPE[512];
	printf("%d : %d", HEAD, *HEAD);
}

void spush(int a)
{
	STACK[SP++] = a;
}

int spop()
{
	return STACK[--SP];
}

int sempty()
{
	if SP {
		return SUCCESS;
	} else {
		return FAILURE;
	}		
}
int sfull()
{
	if (SP==STACK_SIZE) {
		return SUCCESS;
	} else {
		return FAILURE;
	}
}

void mright()
{
	PROGRAM[IC].operator = OP_MRIGHT;
}

void mleft()
{
	PROGRAM[IC].operator = OP_MLEFT;
}

void cadd()
{
	PROGRAM[IC].operator = OP_ADD;
}

void cminus()
{
	PROGRAM[IC].operator = OP_MINUS;
}

void coutput()
{
	PROGRAM[IC].operator = OP_OUTPUT;
}

void cinput()
{
	PROGRAM[IC].operator = OP_INPUT;
}

void mloop()
{
	PROGRAM[IC].operator = OP_LOOP;
	if (sfull()) {
		return FAILURE;
	} else {
		spush(IC);
	}
}

void mloopend()
{
	if (sempty()) {
		return FAILURE;
	} else {
		int tmp_pc = spop();
		PROGRAM[IC].operator = OP_END_LOOP;
		PROGRAM[IC].argument = tmp_pc;
		PROGRAM[tmp_pc].argument = IC;
	}
}

void newproc();
void callproc();

void endprog()
{
	PROGRAM[IC].operator = OP_END;
}
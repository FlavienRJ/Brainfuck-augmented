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
int HEAD;

int IC = 0; //Instruction Counter

t_instruction PROGRAM[PROGRAM_SIZE];
int STACK[STACK_SIZE];
int SP = 0; //Stack pointer
%}

%union{
	char procname;
}

%error-verbose
%token MRIGHT MLEFT ADD MINUS OUTPUT INPUT END
%token LOOP END_LOOP PROCEDURE END_PROCEDURE
%token <procname> PROCNAME

//Rules
%%
program : stmts END 
		;
stmts : stmt
	| stmts stmt 
	| stmts END { printf("End statement\n"); endprog(); YYACCEPT; }
	;
stmt : MRIGHT {  mright(); IC++; }
	| MLEFT {  mleft(); IC++; }
	| ADD {  cadd(); IC++; }
	| MINUS {  cminus(); IC++; }
	| OUTPUT { coutput(); IC++; }
	| INPUT {  cinput(); IC++; }
	| LOOP {  mloop(); IC++; }
	| END_LOOP {  mloopend(); IC++; }
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
	init();
	yyparse();
	fclose(yyin);
	execute();
	return 0;
}

void init()
{
	HEAD = 512;
	printf("[Ox%d] : %d\n", &TAPE[HEAD], TAPE[HEAD]);
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
	if(SP==0) {
		return FAILURE;
	} else {
		return SUCCESS;
	}		
}
int sfull()
{
	if (SP==STACK_SIZE) {
		return FAILURE;
	} else {
		return SUCCESS;
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
		exit(FAILURE);
	} else {
		spush(IC);
	}
}

void mloopend()
{
	if (sempty()) {
		exit(FAILURE);
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

int execute()
{
	IC = 0;
	while (PROGRAM[IC].operator != OP_END && HEAD < TAPE_SIZE && HEAD > 0)
	{
		switch (PROGRAM[IC].operator)
		{
			case OP_MRIGHT: printf("\n[%d] go right\n", IC); HEAD++; break;
			case OP_MLEFT: printf("\n[%d] go left\n", IC); HEAD--; break;
			case OP_ADD: printf("\n[%d] add\n", IC); TAPE[HEAD]++; break;
			case OP_MINUS: printf("\n[%d] decrease\n", IC); TAPE[HEAD]--; break;
			case OP_OUTPUT: printf("\n[%d] print\n", IC); putchar(TAPE[HEAD]); break;
			case OP_INPUT: printf("\n[%d] read\n", IC); TAPE[HEAD] = (int)getchar(); break;
			case OP_LOOP: 
				printf("\n[%d] loop\n", IC);
				if(!TAPE[HEAD]) {
					IC = PROGRAM[IC].argument;
				}
				break;
			case OP_END_LOOP:
				printf("\n[%d] end loop\n", IC);
				if(TAPE[HEAD]) {
					IC = PROGRAM[IC].argument;
				}
				break; 
			default: return FAILURE;
		}
		IC++;
	}
	return SUCCESS;
}
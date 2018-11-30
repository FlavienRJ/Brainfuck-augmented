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

void init();
void mright();
void mleft();
void cadd();
void cminus();
void coutput();
void cinput();
void mloop();
void mloopend();
void newproc();
void callproc();

int TAPE[LEN_TAPE] = {0};
int* head;

int counter = 0;
int loop_stack_counter = 0;
int loop_stack[64];
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
program : stmts { printf("End statement\n"); }
		;
stmts : stmt  
	| stmts stmt  
	;
stmt : MRIGHT { printf("[%d] go right\n", counter); mright(); counter++; }
	| MLEFT { printf("[%d] go left\n", counter); mleft(); counter++; }
	| ADD { printf("[%d] add\n", counter); cadd(); counter++; }
	| MINUS { printf("[%d] decrease\n", counter); cminus(); counter++; }
	| OUTPUT { printf("[%d] print\n", counter); coutput(); counter++; }
	| INPUT { printf("[%d] read\n", counter); cinput(); counter++; }
	| LOOP stmts END_LOOP { printf("[%d] loop\n", counter); mloop(); counter++; }
	| PROCEDURE PROCNAME stmts END_PROCEDURE { printf("[%d] new procedure %c\n", counter, $2); counter++; }
	| PROCNAME { printf("[%d] call procedure %c\n", counter, $1); counter++; }
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
	head = &TAPE[512];
	printf("%d : %d", head, *head);
}

void mright()
{
	head++;
}

void mleft()
{
	head--;
}

void cadd()
{
	(*head)++;
}

void cminus()
{
	(*head)--;
}

void coutput()
{
	putchar(*head);
}

void cinput()
{
	scanf("%d", head);
}

void mloop()
{
	loop_stack[loop_stack_counter] = counter;
	counter++;
}

void mloopend()
{
	
}

void newproc();
void callproc();
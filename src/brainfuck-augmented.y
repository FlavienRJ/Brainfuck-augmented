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
void newproc();
void callproc();

int TAPE[LEN_TAPE] = {0};
int* head;
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
stmt : MRIGHT { printf("go right\n"); mright(); }
	| MLEFT { printf("go left\n"); mleft(); }
	| ADD { printf("add\n"); cadd(); }
	| MINUS { printf("decrease\n"); cminus(); }
	| OUTPUT { printf("print\n"); coutput(); }
	| INPUT { printf("read\n"); cinput(); }
	| LOOP stmts END_LOOP { printf("loop\n"); }
	| PROCEDURE PROCNAME stmts END_PROCEDURE { printf("new procedure %c\n", $2); }
	| PROCNAME { printf("call procedure %c\n", $1); }
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
				strcpy(filename, argv[i]);
				file = 1;
			}
		}
		//compiler
		else if (!strcmp(argv[i], "-c"))
		{
			interpreter = 0;
			if (argv[i+1] != NULL)
			{
				strcpy(filename, argv[i]);
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

void mloop();
void newproc();
void callproc();
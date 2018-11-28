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
stmt : MRIGHT { printf("go right\n"); }
	| MLEFT { printf("go left\n"); }
	| ADD { printf("add\n"); }
	| MINUS { printf("decrease\n"); }
	| OUTPUT { printf("print\n"); }
	| INPUT { printf("read\n"); }
	| LOOP stmts END_LOOP { printf("loop\n"); }
	| PROCEDURE PROCNAME stmts END_PROCEDURE { printf("procedure %c\n", $2); }
	;
%%

void yyerror(const char *s){
	printf("ERROR: %s at line %d\n", s, yylineno); 
}

int main(int argc, char **argv){
	/*if(argc < 2){
		printf("No file to parse!\n");
		return -1;
	}*/
	/*yyin = fopen(argv[1], "r");
	if(yyin == NULL)
		return -1;	*/
	int i = 1;
	char filename[30];
	int visualisation = 0;
	int interpreter = 1; //by default, use interpreter
		//if the option is -i then we want an interpreter
	int file = 0;
	if (i < argc)
	{
		if (strcmp(argv[i], "-i") == 0)
		{
			i++;
			if (i < argc)
			{
				if (!strcmp(argv[i], "-v"))
				{
					visualisation = 1;
				} 
				else
				{
					strcpy(filename, argv[i]);
					file = 1;
					i++;
					if (i < argc)
					{
						if (!strcmp(argv[i], "-v"))
						{
							visualisation = 1;
						} 
					}
				}
			}
		}
		//if the option is -c then we want to compile the file
		else if (!strcmp(argv[i], "-c"))
		{
			i++;
			if (i >= argc)
			{
				printf("No source file to compile!\n");
				return -1;
			}
			else
			{
				//case ./brainfuck-augmented -c -v
				if (strcmp(argv[i], "-v") || strcmp(argv[i], "-i"))
				{
					printf("Wrong order in arguments, needed a file name given an option!\n");
					return -1;
				}
				else
				{
					strcpy(filename, argv[i]);
					file = 1;
				}
				i++;
				if (i < argc)
				{
					//We want the visualisation tool
					if (!strcmp(argv[i], "-v"))
					{
						visualisation = 1;
					}
				}
			}
			interpreter = 0;
		}
		else
		{
			printf("A");
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
	yyparse();
	fclose(yyin);
	return 0;
}

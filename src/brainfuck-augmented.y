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
	char *procname;
}

%error-verbose
%token MRIGHT MLEFT ADD MINUS OUTPUT INPUT 
%token LOOP END_LOOP PROCEDURE END_PROCEDURE
%token <procname> PROCNAME

//Rules
%%
program : stmts {}
		;
stmts : stmt {  }
	| stmts stmt '\n' { printf("End statement\n"); }
	;
stmt : ADD { printf("Add\n"); }
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
	if (!strcmp(argv[i], "-i"))
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
	yyparse();
	fclose(yyin);
	return 0;
}

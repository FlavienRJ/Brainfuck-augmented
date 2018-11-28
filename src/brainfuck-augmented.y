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
	yyparse();
	fclose(yyin);
	return 0;
}

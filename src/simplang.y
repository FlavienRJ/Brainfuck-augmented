%{
#include "simplang.h"
#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <string.h>
extern int yylex(void);
extern int yylineno;
extern FILE *yyin;
void yyerror(const char *s);
t_node *root;
t_node *constToNode(int);
t_node *opToNode(int, int, ...);
t_node *block(t_node *, t_node *);
t_node *strToNode(char *s);
void ex(t_node *p);
void init();
int var_cnt;
t_varNode **variables;
t_node *varToNode(t_varNode*);
%}

%union{
	int val;
	t_varNode *var;
	t_node *node;
	char *s;
}

%error-verbose
%token WHILE READ PRINT IF ELSE ENDIF
%token <val> NUM 
%token <var> VAR
%token <s> STR
%type <node> stmts stmt expr

%right '='
%left '+' '-'
%left '*' '/'
%left NEG

%%
program	: stmts				{ root = $1; }
	;
stmts	: stmt				{ $$ = $1; }
	| stmts stmt			{ $$ = block($1, $2); }
	;
stmt	: PRINT expr ';'		{ $$ = opToNode(PRINT, 1, $2); }
	| PRINT STR ';'		{ $$ = opToNode(PRINT, 1, strToNode($2)); }
	| READ VAR ';'			{ $$ = opToNode(READ, 1, varToNode($2)); }
	| IF expr stmt ENDIF	{ $$ = opToNode(IF, 2, $2, $3); }
	| IF expr stmt ELSE stmt ENDIF	{ $$ = opToNode(ELSE, 3, $2, $3, $5); }	
	| WHILE expr stmt	{ $$ = opToNode(WHILE, 2, $2, $3); }
	| ';'					{ $$ = NULL; }
	| '{' stmts '}'	    	{ $$ = $2; }	
	;
expr	: NUM				{ $$ = constToNode($1); }
	| VAR				{ $$ = varToNode($1); }
	| VAR '=' expr			{ $$ = opToNode('=', 2, varToNode($1), $3); }
	| expr '+' expr 		{ $$ = opToNode('+', 2, $1, $3); }
	| expr '*' expr 		{ $$ = opToNode('*', 2, $1, $3); }
	| expr '/' expr 		{ $$ = opToNode('/', 2, $1, $3); }
	| expr '-' expr			{ $$ = opToNode('-', 2, $1, $3); }
	| '-' expr %prec NEG	{ $$ = opToNode('*', 2, $2, constToNode(-1)); }
	| '(' expr ')'			{ $$ = $2; }
	;
%%

void yyerror(const char *s){
	printf("ERROR: %s at line %d\n", s, yylineno); 
}

int main(int argc, char **argv){
	if(argc < 2){
		printf("No file to parse!\n");
		return -1;
	}
	init(); 
	yyin = fopen(argv[1], "r");
	if(yyin == NULL)
		return -1;	
	yyparse();
	fclose(yyin);
	ex(root);
	return 0;
}

t_node *opToNode(int type, int cnt, ...){
	va_list args;
	t_node *p = malloc(sizeof(t_node));
	p->type = tOp;
	p->op.type = type;
	p->op.n = cnt;
	p->op.operands = malloc(cnt * sizeof(t_node*));
	int i;
	va_start(args, cnt);
	for(i = 0; i < cnt; i++)
		p->op.operands[i] = va_arg(args, t_node*);
	va_end(args);
	return p;
}

t_node *constToNode(int value){
	t_node *p = malloc(sizeof(t_node));
	p->type = tConst;
	p->con.value = value;
	return p;
}

#define BUFLEN 6400
int executeNode(t_node *p){
	if(p == NULL)
		return 0;
	int i;
	char buf[BUFLEN];
	switch(p->type){
		case tConst: return p->con.value;
		case tVar: return p->var->value;
		case tBlock: 
			for(i = 0; i < p->block.n; i++)
				executeNode(p->block.statements[i]);
			return 0;	
		case tOp: switch(p->op.type){
			case WHILE: while(executeNode(p->op.operands[0]))
					executeNode(p->op.operands[1]);
				return 0;
			case IF: if(executeNode(p->op.operands[0]))
					executeNode(p->op.operands[1]);
				return 0;
			case ELSE: if(executeNode(p->op.operands[0]))
					executeNode(p->op.operands[1]);
				else
					executeNode(p->op.operands[2]);
				return 0;
			case PRINT: if(p->op.operands[0]->type == tString)
					printf("%s\n", p->op.operands[0]->str.s);
				    else
					printf("%d\n", executeNode(p->op.operands[0]));
				return 0;
			case READ: fgets(buf, BUFLEN, stdin);				
				p->op.operands[0]->var->value = atoi(buf);
				return 0;			
			case '=': return p->op.operands[0]->var->value = executeNode(p->op.operands[1]);
			case '+': return executeNode(p->op.operands[0]) + executeNode(p->op.operands[1]);
			case '-': return executeNode(p->op.operands[0]) - executeNode(p->op.operands[1]);
			case '/': return executeNode(p->op.operands[0]) / executeNode(p->op.operands[1]);
			case '*': return executeNode(p->op.operands[0]) * executeNode(p->op.operands[1]);
		}
	}
	return 0;
}

void printNode(t_node *p, int level){
	if(p == NULL)
		return;
	int i;
	switch(p->type){
		case tString: 	printf("%*c string: \"%s\"\n", level, ' ', p->str.s); break;
		case tConst: 	printf("%*c const: %d\n", level, ' ', p->con.value); break;
		case tVar: 	printf("%*c var(%s): ? \n", level, ' ', p->var->name); break;
		case tOp: 	printf("%*c op: %d(%c)\n", level, ' ', p->op.type, p->op.type);
			for(i = 0; i < p->op.n; i++)
				printNode(p->op.operands[i], level + 4);
			break;
		case tBlock: printf("%*c block\n", level, ' ');
			for(i = 0; i < p->block.n; i++)
				printNode(p->block.statements[i], level + 4);
			break;
	}
}

void freeNode(t_node *p){
	int i;
	if(p == NULL)
		return;
	switch(p->type){
		case tString: free(p->str.s); 
		case tVar:
		case tConst: free(p); break;
		case tOp: 
			for(i = 0; i < p->op.n; i++)
				freeNode(p->op.operands[i]);
			free(p);
			break;
		case tBlock: 
			for(i = 0; i < p->block.n; i++)
				freeNode(p->block.statements[i]);
			free(p);
			break;
	}
}

void ex(t_node *p){
	printNode(p, 0);
	executeNode(p);
	freeNode(p);
}

t_varNode *newVar(char *name){
	t_varNode *v = malloc(sizeof(t_varNode));
	v->name = strdup(name);
	v->value = 0; //all new variables are zeroed at the start //optional
	var_cnt++;
	variables = realloc(variables, var_cnt * sizeof(t_varNode*));
	variables[var_cnt - 1] = v;
	return v;
}

t_varNode *findVar(char *name){
	int i;
	for(i = 0; i < var_cnt; i++)
		if(strcasecmp(variables[i]->name, name) == 0)
			return variables[i];
	return newVar(name);
}

t_node *varToNode(t_varNode *var){
	t_node *p = malloc(sizeof(t_node));
	p->type = tVar;
	p->var = var;
	return p;
}

void init(void){
	root = NULL;
	var_cnt = 0;
	variables = NULL;
}

t_node *strToNode(char *s){ 
	t_node *p = malloc(sizeof(t_node));
	p->type = tString;
	p->str.s = s;
	return p;
}

t_node *block(t_node *a, t_node *b){ 
	if(a == NULL && b != NULL)
		return b;
	if(a != NULL && b == NULL)
		return a;
	if(a == NULL && b == NULL)
		return NULL;
	if(a->type == tBlock){
		a->block.n++;
		a->block.statements = realloc(a->block.statements, a->block.n * sizeof(void*));
		a->block.statements[a->block.n - 1] = b;
		return a;
	}else{
		t_node *p = malloc(sizeof(t_node));
		p->type = tBlock;
		p->block.n = 2;
		p->block.statements = malloc(2 * sizeof(void*));		
		p->block.statements[0] = a;
		p->block.statements[1] = b;
		return p;
	}
}


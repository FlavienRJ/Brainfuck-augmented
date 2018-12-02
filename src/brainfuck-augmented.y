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
t_fn_instruction PROC[STACK_SIZE];
int PP = 0;
int inProc = 0; //if 1 then put the instruction in the buffer of the procedure of PROC[PP]
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
program : stmts 
		;
stmts : stmt
	| stmts stmt 
	| stmts END { endprog(); execute(); cleanprog(); }
	;
stmt : MRIGHT {  mright(); IC++; }
	| MLEFT {  mleft(); IC++; }
	| ADD {  cadd(); IC++; }
	| MINUS {  cminus(); IC++; }
	| OUTPUT { coutput(); IC++; }
	| INPUT {  cinput(); IC++; }
	| LOOP {  mloop(); IC++; }
	| END_LOOP {  mloopend(); IC++; }
	| PROCEDURE PROCNAME { newproc($2); IC++; }
	| END_PROCEDURE { endproc(); IC++; }
	| PROCNAME { callproc($1); IC++; }
	;
%%
//think about a better version than YYACCEPT because of difference interpreter/file
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
	if(debug) {printf("[Ox%d] : %d\n", &TAPE[HEAD], TAPE[HEAD]);}
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
	if (inProc)
		PROC[PP].size++;
	PROGRAM[IC].operator = OP_MRIGHT;
}

void mleft()
{
	if (inProc)
	{
		PROC[PP].PROC_INSTR[PROC[PP].size].operator = OP_MLEFT;
		PROC[PP].size++;
	}
	else
	{
		PROGRAM[IC].operator = OP_MLEFT;
	}
	
}

void cadd()
{
	if (inProc)
	{
		PROC[PP].PROC_INSTR[PROC[PP].size].operator = OP_ADD;
		PROC[PP].size++;
	}
	else
	{
		PROGRAM[IC].operator = OP_ADD;
	}
}

void cminus()
{
	if (inProc)
	{
		PROC[PP].PROC_INSTR[PROC[PP].size].operator = OP_MINUS;
		PROC[PP].size++;
	}
	else
	{
		PROGRAM[IC].operator = OP_MINUS;
	}
}

void coutput()
{
	if (inProc)
	{
		PROC[PP].PROC_INSTR[PROC[PP].size].operator = OP_OUTPUT;
		PROC[PP].size++;
	}
	else
	{
		PROGRAM[IC].operator = OP_OUTPUT;
	}
}

void cinput()
{
	if (inProc)
	{
		PROC[PP].PROC_INSTR[PROC[PP].size].operator = OP_INPUT;
		PROC[PP].size++;
	}
	else
	{
		PROGRAM[IC].operator = OP_INPUT;
	}
}

void mloop()
{
	if (inProc)
		PROC[PP].size++;
	PROGRAM[IC].operator = OP_LOOP;
	if (sfull()) {
		exit(FAILURE);
	} else {
		spush(IC);
	}
}

void mloopend()
{
	if (inProc)
		PROC[PP].size++;
	if (sempty()) {
		exit(FAILURE);
	} else {
		int tmp_pc = spop();
		PROGRAM[IC].operator = OP_END_LOOP;
		PROGRAM[IC].argument = tmp_pc;
		PROGRAM[tmp_pc].argument = IC;
	}		
}

void newproc(char procname)
{
	inProc = 1;
	PROGRAM[IC].operator = OP_NEW_PROC;
	PROGRAM[IC].name = procname;
	PROC[PP].name = procname;
	PROC[PP].IC_begin = IC + 1;
	PROC[PP].size = 0;
	
	//t_instruction* instr = malloc(128 * sizeof(t_instruction));
}

void endproc()
{
	PROGRAM[IC].operator = OP_END_PROC;
	inProc = 0;	
	PP++;
}

void callproc(char procname)
{
	PROGRAM[IC].operator = OP_CALL_PROC;
	PROGRAM[IC].name = procname;
}

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
			case OP_MRIGHT: if(debug) {printf("\n[%d] go right\n", IC);} HEAD++; break;
			case OP_MLEFT: if(debug) {printf("\n[%d] go left\n", IC);} HEAD--; break;
			case OP_ADD: if(debug) {printf("\n[%d] add\n", IC);} TAPE[HEAD]++; break;
			case OP_MINUS: if(debug) {printf("\n[%d] decrease\n", IC);} TAPE[HEAD]--; break;
			case OP_OUTPUT: if(debug) {printf("\n[%d] print\n", IC);} putchar(TAPE[HEAD]); break;
			//I think there is a problem with the reading from the stdin
			case OP_INPUT: 
				if(debug) {printf("\n[%d] read\n", IC);}
				//fflush(); //error to reading but i am to tired to fix it
				TAPE[HEAD] = (int)getchar();
				break;
			case OP_LOOP: 
				if(debug) {printf("\n[%d] loop\n", IC);}
				if(!TAPE[HEAD]) {
					IC = PROGRAM[IC].argument;
				}
				break;
			case OP_END_LOOP:
				if(debug) {printf("\n[%d] end loop\n", IC);}
				if(TAPE[HEAD]) {
					IC = PROGRAM[IC].argument;
				}
				break; 
			case OP_NEW_PROC:
				if(debug) {printf("\n[%d] new proc : %c\n", IC, PROGRAM[IC].name);}
				break;
			case OP_END_PROC:
				break;
			case OP_CALL_PROC:
				if(debug) {printf("\n[%d] call proc : %c\n", IC, PROGRAM[IC].name);}
				executeproc(PROGRAM[IC].name);
				break;

			default: return FAILURE;
		}
		IC++;
	}
	return SUCCESS;
}

void executeproc(char procname)
{
	int i = 0;
	if(debug) { printf("\n[%d] executeproc: %c\n", IC, procname);}
	int k,l;
	for (k = 0; k < PP; k++)
	{
		printf("procname = %c\n", PROC[k].name);
		for (l=0; l < PROC[k].size; l++)
		{
			printf ("\tOp code : %d\n", PROC[k].PROC_INSTR[l].operator);
		}
	}
	for (i = 0; i < PP; i++)
	{
		if (PROC[i].name == procname)
		{
			if(debug) {printf("Procedure %c found\n", procname); }
			int j;
			for (j = 0; j < PROC[i].size; j++)
			{
				//Need to do in other way
				switch (PROC[i].PROC_INSTR[j].operator)
				{
					case OP_MRIGHT: if(debug) {printf("\n[%d] go right\n", IC);} HEAD++; break;
					case OP_MLEFT: if(debug) {printf("\n[%d] go left\n", IC);} HEAD--; break;
					case OP_ADD: if(debug) {printf("\n[%d] add\n", IC);} TAPE[HEAD]++; break;
					case OP_MINUS: if(debug) {printf("\n[%d] decrease\n", IC);} TAPE[HEAD]--; break;
					case OP_OUTPUT: if(debug) {printf("\n[%d] print\n", IC);} putchar(TAPE[HEAD]); break;
					//I think there is a problem with the reading from the stdin
					case OP_INPUT: 
						if(debug) {printf("\n[%d] read\n", IC);}
						//fflush(); //error to reading but i am to tired to fix it
						TAPE[HEAD] = (int)getchar();
						break;	
					default:
						break;	
				}		
			}
			return;
		}
	}
	printf("Procedure %c does not exist\n",procname);
}

void cleanprog()
{
	IC = 0;
	memset(PROGRAM, 0, sizeof(PROGRAM));
}
void cleantape()
{
	HEAD = 512;
	memset(TAPE, 0, sizeof(TAPE));
}
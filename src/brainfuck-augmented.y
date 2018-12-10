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
int interpreter = 0;
int debug = 1;
int file = 0;
int compiler = 1;

int TAPE[TAPE_SIZE] = {0};
int HEAD;
FILE * cfile = NULL; //pointer to the file for the compiler

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
%token CLEAN GOTO
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
	| CLEAN { if(debug){printf("clean tape by user\n"); } cleantape(); }
	;
%%
void yyerror(const char *s){
	printf("ERROR: %s at line %d\n", s, yylineno);
}

/* Documentation argument for main
*	-i : interactive console with interpreter
*	-i filename : interpret the code
*	-d : enable print debug informations
*	-v : enable visualization tool --> show the tape
*	-c filename : translate in c the filename
*/
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
			//interpreter = 0;
			compiler = 1;
			if (argv[i+1] != NULL)
			{
				strcpy(filename, argv[i+1]); //here we get the filename which I should translate to c
				file = 1;
				//open a new file to write code to
				cfile = fopen("brainfuckInC.c", "w");
				if (debug){
					if(cfile == NULL){ printf("error opening a new .c file\n");}
					else{ printf("successfull opend a new c file\n");}
				}
			}
			else
			{
				printf("No source file to translate!\n");
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
	HEAD = TAPE_SIZE/2;
	if(debug) {printf("[Ox%d] : %d\n", &TAPE[HEAD], TAPE[HEAD]);}
	if(compiler){
		fprintf(cfile, "int TapeArray[%d] = {0};\n", TAPE_SIZE);
		fprintf(cfile, "int main(){\n");
	}
}

//stack implementation
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
	{
		PROC[PP].PROC_INSTR[PROC[PP].size].operator = OP_LOOP;
		PROC[PP].size++;
	}

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
	if(findProcname(procname) >= 0)
	{
		printf("procedure %c already exists\n", procname);
		inProc = 0;
	}
	else
	{
		inProc = 1;
		PROGRAM[IC].operator = OP_NEW_PROC;
		PROGRAM[IC].name = procname;
		PROC[PP].name = procname;
		PROC[PP].IC_begin = IC + 1;
		PROC[PP].size = 0;
		PROC[PP].stack_size = 0;
	}
	//t_instruction* instr = malloc(128 * sizeof(t_instruction));
}

int findProcname(char procname)
{
	int i = 0;
	for (i = 0; i < PP; i++)
	{
		if (PROC[i].name == procname)
		{
			return i;
		}
	}
	return -1;
}

void endproc()
{
	if(inProc==1)
	{
		PROGRAM[IC].operator = OP_END_PROC;
		inProc = 0;
		PP++;
	}
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

/** writes every intructio into the cfile**/
void writeToCFile(){
 	/* code */
 }

void endCfile(){
	 if(cfile == NULL){
		 printf("no c file for endinf the c file\n");
	 }else{
	 		fprintf(cfile, " return 0; \n }");
			fclose(cfile);
 		}
 }

int execute()
{
	IC = 0;
	while (PROGRAM[IC].operator != OP_END && HEAD < TAPE_SIZE && HEAD > 0)
	{
		if (executeInstr(PROGRAM[IC],IC) == FAILURE)
		{
			printf("Error during execution of instruction [%d]\n",IC);
			return FAILURE;
		}
		IC++;
		if(visualisation){tape_visualisation(); }
		//if(compiler){writeToCFile();}
	}
	if(compiler){endCfile();}
	return SUCCESS;
}

int executeInstr(t_instruction instr, int ic)
{
	switch (instr.operator)
	{
		case OP_MRIGHT:
			/*if(debug) {printf("\n[%d] go right\n", ic);}*/
			HEAD++;
			 break;
		case OP_MLEFT: /*if(debug) {printf("\n[%d] go left\n", ic);}*/ HEAD--; break;
		case OP_ADD:
		 	/*if(debug) {printf("\n[%d] increase\n", ic);}*/
			TAPE[HEAD]++;
			if(compiler){fprintf(cfile, "TapeArray[%d]+=1;\n",HEAD);} //optimisation possibility
			break;
		case OP_MINUS: /*if(debug) {printf("\n[%d] decrease\n", ic);}*/
			TAPE[HEAD]--;
			if(compiler){fprintf(cfile, "TapeArray[%d]-=1;\n",HEAD);} //optimisation possibility
			break;
		case OP_OUTPUT: /*if(debug) {printf("\n[%d] print\n", ic);}*/
			printf("(%d)\t%c \n",TAPE[HEAD],TAPE[HEAD]);
			if(compiler){fprintf(cfile, "printf(%"(%%d)%\t %%c %\n%",TapeArray[%d],TapeArray[%d]);\n",HEAD,);} 
			break;
		//we have a new [number]\t ascii representation
		//I think there is a problem with the reading from the stdin
		case OP_INPUT:
			if(debug) {printf("\n[%d] read\n", ic);}
			//fflush(); //error to reading but i am to tired to fix it
			int c;
			c = (int)(getchar());
			if (c > 47 && c < 58) //If user enter a number, but this number and not its representation in ASCII
			{
				c -= '0';
			}
			TAPE[HEAD] = c;
			break;
		case OP_LOOP:
			/*if(debug) {printf("\n[%d] loop\n", ic);}*/
			if(!TAPE[HEAD]) {
				IC = PROGRAM[IC].argument;
			}
			break;
		case OP_END_LOOP:
			/*if(debug) {printf("\n[%d] end loop\n", ic);}*/
			if(TAPE[HEAD]) {
				IC = PROGRAM[IC].argument;
			}
			break;
		case OP_NEW_PROC:
			if(debug) {printf("\n[%d] new proc : %c\n", ic, PROGRAM[ic].name);}
			break;
		case OP_END_PROC:
			break;
		case OP_CALL_PROC:
			if(debug) {printf("\n[%d] call proc : %c\n", IC, PROGRAM[ic].name);}
			executeproc(PROGRAM[IC].name);
			break;

		default: return FAILURE;
	}
	return SUCCESS;
}

int executeproc(char procname)
{
	int i = 0;
	if(debug)
	{
		printf("\n[%d] executeproc: %c\n", IC, procname);
		int k,l;
		for (k = 0; k < PP; k++)
		{
			printf("procname = %c\n", PROC[k].name);
			for (l=0; l < PROC[k].size; l++)
			{
				printf ("\tOpcode%d : %d\n",l, PROC[k].PROC_INSTR[l].operator);
			}
		}
	}
	i = findProcname(procname);
	if( i >= 0)
	{
		if(debug) {printf("Procedure %c found\n", procname); }
		int j;
		for (j = 0; j < PROC[i].size; j++)
		{
			if (executeInstr(PROC[i].PROC_INSTR[j],j) == FAILURE)
			{
				printf("Error during execution of instruction [%d] in procedure %c\n",j,PROC[i].name);
				return FAILURE;
			}
			if(visualisation){tape_visualisation(); }
		}
		return SUCCESS;
	}
	printf("Procedure %c does not exist\n",procname);
	return FAILURE;

}

void cleanprog()
{
	IC = 0;
	memset(PROGRAM, 0, sizeof(PROGRAM));
}
void cleantape()
{
	HEAD = TAPE_SIZE/2;
	memset(TAPE, 0, sizeof(TAPE));
}

void tape_visualisation()
{
	int i = 0;
	char middle[256];
	memset(middle, 0, sizeof(middle));
	char top_bot[256];
	memset(top_bot, 0, sizeof(top_bot));

	while ( TAPE[i] == 0 && i < TAPE_SIZE)
		i++;
	if(i == TAPE_SIZE)
	{
		strcat(middle, "| ... |");
	}
	else
	{
		if(i==0)
		{
			strcat(middle,"|");
		}
		else
		{
			strcat(middle,"| ... |");
		}
		while (i < TAPE_SIZE)
		{
			if (TAPE[i] == 0)
			{
				strcat(middle," ... |");
				while (TAPE[i] == 0 && i < TAPE_SIZE)
					i++;
			}
			else
			{
				char buf[8];
				strcat(middle," ");
				if(i==HEAD)
				{
					strcat(middle, "#");
				}
				sprintf(buf, "%d",TAPE[i]);
				strcat(middle, buf);
				strcat(middle," |");
				i++;
			}
		}
	}

	for (i = 0; i < strlen(middle); i++)
		top_bot[i] = '-';
	top_bot[i+1] = '\0';
	printf("%s\n", top_bot);
	printf("%s\n", middle);
	printf("%s\n", top_bot);
}

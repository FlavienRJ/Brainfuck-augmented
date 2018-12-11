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
int compiler = 0;
int compileObject = 0;

//FRJ - useless for C program. Maybe use a global variable to count the number of \t is a better idea
int insideLoop = 0; //otherwise the compiler prints the loop too often
//FRJ - don't understand what is it ?
char tab = '\t';  //formating the compiled c file

int TAPE[TAPE_SIZE] = {0};
int HEAD;
FILE * cfile = NULL; //pointer to the file for the compiler //FRJ - never a good idea to have a pointer on a file in global function -> side-effect problems while happen

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
*	-o filename : compile filename in generating c file
*	-a nbArg arg1 arg2 ... argN : fill the tape with value
*/
int main(int argc, char **argv)
{
	int i;
	char filename[30];
	init();
  
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
			compileObject = 1;
			if (argv[i+1] != NULL)
			{
				strcpy(filename, argv[i+1]); //here we get the filename which I should translate to c
				file = 1;
				//open a new file to write code to
				cfile = fopen("build/brainfuckInC.c", "w"); //FRJ - Maybe compile file filename.c and not this name
				if (debug){
					if(cfile == NULL){ printf("error opening a new .c file\n");}
					else{ printf("successfully opend a new c file\n");}
				}
			}
			else
			{
				printf("No source file to translate!\n");
				return -1;
			}
		}
		else if (!strcmp(argv[i], "-o"))
		{
			interpreter = 0;
			compiler = 1;
			if (argv[i+1] != NULL)
			{
				strcpy(filename, argv[i+1]); //here we get the filename which I should translate to c
				file = 1;
				//open a new file to write code to
				cfile = fopen("build/brainfuckInC.c", "w"); //FRJ - Maybe compile file filename.c and not this name
				if (debug){
					if(cfile == NULL){ printf("error opening a new .c file\n");}
					else{ printf("successfully opened a new c file\n");}
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
		//arguments
		else if (!strcmp(argv[i], "-a"))
		{
			i++;
			int nbArg = atoi(argv[i]);
			int j;
			for (j = 0; j < nbArg; j++)
			{
				TAPE[HEAD + j] = atoi(argv[++i]);
				if(debug){printf("add arg%d in the tape = %d\n", j, TAPE[HEAD + j]);}
			}
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
	yyparse();	
	fclose(yyin);
	//compile or execute
	if (interpreter == 1){
		execute();
	}

	if (compiler == 1){
		translate();
	}

	if (compiler == 1){
		compile();
	}
	return 0;
}

//FRJ - don't forget do declare your function's prototype, without the compiler will give you a warning. Try to avoid warnings -> side-effect
int translate()
{
	IC = 0;
	while (PROGRAM[IC].operator != OP_END && HEAD < TAPE_SIZE && HEAD > 0)
	{
		if (writeToCFile(PROGRAM[IC],IC) == FAILURE){
			printf("Error during converting of instruction [%d] to c\n",IC);
			return FAILURE;
		}
		IC++;
	}
	endCfile();
	return SUCCESS;
}
int compile()
{
	translate();
	const char* cmd = "gcc build/brainfuckInC.c"; //FRJ - change with the right name
	if (system(cmd) == -1)
	{
		printf("Error during compiling the C file\n");
	}
}

void init()
{
	HEAD = TAPE_SIZE/2;
	if(debug) {printf("[Ox%d] : %d\n", &TAPE[HEAD], TAPE[HEAD]);}
	if(compiler){
		//FRJ - Maybe add the #include
		fprintf(cfile, "int TapeArray[%d] = {0};\n", TAPE_SIZE);
		fprintf(cfile,"int head = %d;\n\n", HEAD); //with out this loops are not working
		fprintf(cfile, "int main ( int argc, char *argv[] ){\n");
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
	{
		PROC[PP].PROC_INSTR[PROC[PP].size].operator = OP_MRIGHT;
		PROC[PP].size++;
	}
	else
	{
		PROGRAM[IC].operator = OP_MRIGHT;
	}
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

//Before call a procedure, be sure to add it in the program before
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

 //for the compiler and procedures
int writeProctoC(char procname)
{
	int i = 0;
 	if(debug)
 	{
 		printf("\n[%d] convert proc: %c\n", IC, procname);
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
 			if (writeToCFile(PROC[i].PROC_INSTR[j],j) == FAILURE)
 			{
 				printf("Error during execution of instruction [%d] in procedure %c\n",j,PROC[i].name);
 				return FAILURE;
 			}
			else{
				fprintf(cfile, "\t" );
			}
				//if(visualisation){tape_visualisation(); }
 		}
 		return SUCCESS;
 	}
 	printf("Procedure %c does not exist\n",procname);
 	return FAILURE;
}

/** writes every intructio into the cfile, similar like executeInstr()**/
int writeToCFile(t_instruction instr, int ic){
		switch (instr.operator)
		{
			case OP_MRIGHT:
			/*if(debug) {printf("\n[%d] go right\n", ic);}*/
				fprintf(cfile, "%c head+=1;\n", tab);
				break;
			case OP_MLEFT:
				//FRJ - HEAD why do you need head ?
				/*if(debug) {printf("\n[%d] go left\n", ic);}*/
				fprintf(cfile, "%c head-=1;\n", tab);
				break;
			case OP_ADD:
			 	if(debug) {printf("\n [%d] increase\n", ic);}
				fprintf(cfile, "%c TapeArray[head]+=1;\n", tab); //optimisation possibility //FRJ - Optimisation necessary
				break;
			case OP_MINUS:
				if(debug) {printf("\n [%d] decrease\n", ic);}
				fprintf(cfile, "%c TapeArray[head]-=1;\n", tab); //optimisation possibility //FRJ - your if(compiler) is useless
				break;
			case OP_OUTPUT:
				if(debug) {printf("\n[%d] print\n", ic);}
				//FRJ - Check this, you don't want to print HEAD I think. Also check warnings 
				/*
				brainfuck-augmented.y:450:40: warning: invalid conversion specifier ' '
					[-Wformat-invalid-specifier]
												fprintf(cfile, "%c printf(\"(%d)\%t \%c \\n \",TapeArray[...
																				~~~^
				brainfuck-augmented.y:450:63: warning: more '%' conversions than data arguments [-Wformat]
				...fprintf(cfile, "%c printf(\"(%d)\%t \%c \\n \",TapeArray[%d]);\n",tab,HEAD,HEAD);
				*/
				fprintf(cfile, "%cprintf(\"(%d)\%t \%c \\n \",TapeArray[%d]);\n",tab,HEAD,HEAD);
				break;
			//I think there is a problem with the reading from the stdin
			case OP_INPUT:
				if(debug) {printf("\n[%d] read\n", ic);}
				//FRJ - just a scanf() doesn't work ?
				break;
			case OP_LOOP:
				/*if(debug) {printf("\n[%d] loop\n", ic);}*/
				fprintf(cfile, "%c if (!TapeArray[%d] ) {\n",tab, HEAD);
				//FRJ - Why did you that ?!? only a while(!TapeArray[%d]){} and \t for all instruction on it
				insideLoop++;
				//snprintf();change the tab
				break;
			case OP_END_LOOP:
				/*if(debug) {printf("\n[%d] end loop\n", ic);}*/
				fprintf(cfile, "%c }\n", tab);
				insideLoop -= 1; //FRJ - useless
				break;
			case OP_NEW_PROC:
				if(debug) {printf("\n[%d] new proc : %c\n", ic, PROGRAM[ic].name);}
				fprintf(cfile, "%c void %c(){\n", tab, PROGRAM[ic].name);
				//FRJ - use the number of tab
				//writeProctoC(PROGRAM[ic].name);
				break;
			case OP_END_PROC:
				writeProctoC(PROGRAM[IC].name);
				fprintf(cfile, "%c}\n",tab);
				break;
			case OP_CALL_PROC:
				if(debug) {printf("\n[%d] call proc : %c\n", IC, PROGRAM[ic].name);}
				fprintf(cfile, "%c %c();\n", tab, PROGRAM[ic].name);
				break;

			default: return FAILURE;//i don´t have every case, maybe I should add them to not get a FAILURE
		}
		/*if (debug){
			int l = sizeof(tab);
			printf("%d\n", l);
		}*/
		return SUCCESS;
 }

// FRJ - This function is never called. Check why
void endCfile()
{
	 if(cfile == NULL)
	 {
		 printf("no c file for endinf the c file\n");
	 }
	 else
	 {
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
	}
	return SUCCESS;
}

int executeInstr(t_instruction instr, int ic)
{
	switch (instr.operator)
	{
		case OP_MRIGHT:
			if(debug) {printf("\n[%d] go right\n", ic);}
			HEAD++;
			 break;
		case OP_MLEFT: if(debug) {printf("\n[%d] go left\n", ic);} HEAD--; break;
		case OP_ADD:
		 	if(debug) {printf("\n[%d] increase\n", ic);}
			TAPE[HEAD]++;
			break;
		case OP_MINUS: if(debug) {printf("\n[%d] decrease\n", ic);}
			TAPE[HEAD]--;
			break;
		case OP_OUTPUT: if(debug) {printf("\n[%d] print\n", ic);}
			printf("(%d)\t%c \n",TAPE[HEAD],TAPE[HEAD]);
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
			if(debug) {printf("\n[%d] loop\n", ic);}
			if(!TAPE[HEAD]) {
				IC = PROGRAM[IC].argument;
			}
			break;
		case OP_END_LOOP:
			if(debug) {printf("\n[%d] end loop\n", ic);}
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

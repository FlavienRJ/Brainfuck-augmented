%top{
#include "brainfuck-augmented.h"
#include "brainfuck-augmented.tab.h"
}

%option noyywrap
%option yylineno
%option case-insensitive
%%

"\#"			; //Comments
"\>"            { return MRIGHT; }
"\<"            { return MLEFT; }
"\+"            { return ADD; }
"\-"            { return MINUS; }
"\."            { return OUTPUT; }
"\,"            { return INPUT; }
"\["            { return LOOP; }
"\]"            { return END_LOOP; } //not sure about it, getVal to define  
"\:"            { return PROCEDURE; }
[A-Z]           { yylval.procname = yytext[0]; return PROCNAME; } 
"\;"            { return END_PROCEDURE; }
"\$"            { return CLEAN; }
"\@"            { return GOTO; }
"\n\n"            { return END; }
"\n"        ;
"\t"        ;
.			;

%%
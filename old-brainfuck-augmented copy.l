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
"\>"            { return MLEFT; }
"\+"            { return ADD; }
"\-"            { return MINUS; }
"\."            { return PRINT; }
"\,"            { return INPUT; }
"\["            { BEGIN(LOOP); }
<LOOP>"\]"      {   if(!getVal()) 
                    { 
                        BEGIN(INITIAL);
                    }
                } //not sure about it, getVal to define   
"\:"            { BEGIN(PROCEDURE); }
<PROCEDURE>[A-Z]           { yylval.s = return PROCNAME; } 
<PROCEDURE>"\;"     {BEGIN(INITIAL); }
\n			;
.			;

%%
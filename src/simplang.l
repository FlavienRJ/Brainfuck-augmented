%top{
#include "simplang.h"
#include "simplang.tab.h"
}

%option noyywrap
%option yylineno
%option case-insensitive
%x STRING

%%

"IF"			{ return IF; }
"ELSE"			{ return ELSE; }
"ENDIF"			{ return ENDIF; }
"WHILE"			{ return WHILE; }
"READ"			{ return READ; }
"PRINT"			{ return PRINT; }
[a-z][a-z0-9]*		{ yylval.var = findVar(yytext); return VAR; }
[0-9]+			{ yylval.val = atoi(yytext); return NUM; }
\"			{ BEGIN(STRING); }
<STRING>[^\"]+		{ yylval.s = strdup(yytext); return STR; }
<STRING>\"		{ BEGIN(INITIAL); }
[\+\*\-\/()={};] 	{ return *yytext; } 
\n			;
.			;

%%
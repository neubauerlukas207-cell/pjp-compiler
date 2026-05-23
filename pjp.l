%{
#include "pjp.tab.h"
#include <string.h>
#include <ctype.h>
#include <stdlib.h>

void to_upper(char *s) {
    for (; *s; s++) *s = toupper((unsigned char)*s);
}
%}

%option noyywrap
%option yylineno

DIGIT       [0-9]
ALPHA       [a-zA-Z]
ALNUM       [a-zA-Z0-9]

%%

[ \t\r\n]+          { /* skip whitespace */ }

"{"[^}]*"}"         { /* skip { } comments */ }
"(*"([^*]|\*+[^)])*\*+")"  { /* skip (* *) comments */ }

"program"           { return PROGRAM; }
"PROGRAM"           { return PROGRAM; }
"var"               { return VAR; }
"VAR"               { return VAR; }
"integer"           { return INTEGER; }
"INTEGER"           { return INTEGER; }
"char"              { return CHAR; }
"CHAR"              { return CHAR; }
"begin"             { return BEGIN_T; }
"BEGIN"             { return BEGIN_T; }
"end"               { return END_T; }
"END"               { return END_T; }
"if"                { return IF; }
"IF"                { return IF; }
"then"              { return THEN; }
"THEN"              { return THEN; }
"else"              { return ELSE; }
"ELSE"              { return ELSE; }
"while"             { return WHILE; }
"WHILE"             { return WHILE; }
"do"                { return DO; }
"DO"                { return DO; }
"div"               { return DIV_OP; }
"DIV"               { return DIV_OP; }
"mod"               { return MOD_OP; }
"MOD"               { return MOD_OP; }
"or"                { return OR_OP; }
"OR"                { return OR_OP; }
"and"               { return AND_OP; }
"AND"               { return AND_OP; }
"not"               { return NOT_OP; }
"NOT"               { return NOT_OP; }

":="                { return ASSIGN; }
"<>"                { yylval.str = strdup("!="); return RELOP; }
"<="                { yylval.str = strdup("<="); return RELOP; }
">="                { yylval.str = strdup(">="); return RELOP; }
"<"                 { yylval.str = strdup("<");  return RELOP; }
">"                 { yylval.str = strdup(">");  return RELOP; }
"="                 { yylval.str = strdup("=="); return RELOP; }

"+"                 { return '+'; }
"-"                 { return '-'; }
"*"                 { return '*'; }
"/"                 { return '/'; }

"."                 { return '.'; }
","                 { return ','; }
";"                 { return ';'; }
":"                 { return ':'; }
"("                 { return '('; }
")"                 { return ')'; }

{DIGIT}{1,10}       {
                        yylval.str = strdup(yytext);
                        return NUM;
                    }

"#"[+-]?{DIGIT}+    {
                        int val = atoi(yytext + 1);
                        char buf[8];
                        snprintf(buf, sizeof(buf), "'%c'", (char)val);
                        yylval.str = strdup(buf);
                        return CHAR_CONST;
                    }

"'"[^']"'"          {
                        char buf[8];
                        snprintf(buf, sizeof(buf), "'%c'", yytext[1]);
                        yylval.str = strdup(buf);
                        return CHAR_CONST;
                    }

{ALPHA}{ALNUM}{0,9} {
                        char tmp[16];
                        strncpy(tmp, yytext, 15);
                        tmp[15] = '\0';
                        to_upper(tmp);
                        yylval.str = strdup(tmp);
                        return ID;
                    }

.                   {
                        fprintf(stderr, "Lexikalni chyba: neznamy znak '%s' na radku %d\n", yytext, yylineno);
                        exit(1);
                    }

%%

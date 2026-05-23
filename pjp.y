%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdarg.h>

extern int yylineno;
int yylex(void);
void yyerror(const char *s);

/* TAC helpers */
static int temp_cnt = 0;
static int label_cnt = 0;

char *new_temp(void) {
    char *t = malloc(16);
    snprintf(t, 16, "T%d", temp_cnt++);
    return t;
}

char *new_label(void) {
    char *l = malloc(16);
    snprintf(l, 16, "L%d", label_cnt++);
    return l;
}

/* Label stacks */
#define STACK_SIZE 64
static char *if_stack[STACK_SIZE];   static int if_top = 0;
static char *else_stack[STACK_SIZE]; static int else_top = 0;
static char *ws_stack[STACK_SIZE];   static int ws_top = 0;
static char *we_stack[STACK_SIZE];   static int we_top = 0;

void push_if_label(char *l)    { if_stack[if_top++] = l; }
char *pop_if_label(void)       { return if_stack[--if_top]; }
void push_else_label(char *l)  { else_stack[else_top++] = l; }
char *pop_else_label(void)     { return else_stack[--else_top]; }
void push_while_start(char *l) { ws_stack[ws_top++] = l; }
char *pop_while_start(void)    { return ws_stack[--ws_top]; }
void push_while_end(char *l)   { we_stack[we_top++] = l; }
char *pop_while_end(void)      { return we_stack[--we_top]; }
%}

%union {
    char *str;
}

%token <str> ID NUM CHAR_CONST RELOP
%token PROGRAM VAR INTEGER CHAR BEGIN_T END_T IF THEN ELSE WHILE DO
%token ASSIGN DIV_OP MOD_OP OR_OP AND_OP NOT_OP

%type <str> vyraz jednoduchy_vyraz terminalni_vyraz faktor promenna

%%

program:
    PROGRAM ID '(' netypovany_seznam_id ')' ';'
    deklarace
    slozeny_prikaz
    '.'
    ;

netypovany_seznam_id:
    ID
    | netypovany_seznam_id ',' ID
    ;

deklarace:
    /* epsilon */
    | deklarace VAR seznam_identifikatoru ';'
    ;

seznam_identifikatoru:
    ID typovany_seznam_id
    ;

typovany_seznam_id:
    ',' ID typovany_seznam_id
    | ':' typ
    ;

typ:
    standardni_typ
    | /* epsilon */
    ;

standardni_typ:
    INTEGER
    | CHAR
    ;

slozeny_prikaz:
    BEGIN_T volitelne_prikazy END_T
    ;

volitelne_prikazy:
    /* epsilon */
    | seznam_prikazu
    ;

seznam_prikazu:
    prikaz
    | seznam_prikazu ';' prikaz
    ;

prikaz:
    promenna ASSIGN vyraz
        {
            printf("%s = %s\n", $1, $3);
            free($1); free($3);
        }
    | slozeny_prikaz
    | IF vyraz THEN
        {
            char *lfalse = new_label();
            printf("if not %s goto %s\n", $2, lfalse);
            free($2);
            push_if_label(lfalse);
        }
      prikaz else_cast
    | WHILE
        {
            char *ls = new_label();
            printf("%s:\n", ls);
            push_while_start(ls);
        }
      vyraz DO
        {
            char *le = new_label();
            printf("if not %s goto %s\n", $3, le);
            free($3);
            push_while_end(le);
        }
      prikaz
        {
            char *ls = pop_while_start();
            char *le = pop_while_end();
            printf("goto %s\n", ls);
            printf("%s:\n", le);
            free(ls); free(le);
        }
    ;

else_cast:
    ELSE
        {
            char *lend = new_label();
            char *lfalse = pop_if_label();
            printf("goto %s\n", lend);
            printf("%s:\n", lfalse);
            free(lfalse);
            push_else_label(lend);
        }
      prikaz
        {
            char *lend = pop_else_label();
            printf("%s:\n", lend);
            free(lend);
        }
    | /* epsilon */
        {
            char *lfalse = pop_if_label();
            printf("%s:\n", lfalse);
            free(lfalse);
        }
    ;

promenna:
    ID  { $$ = $1; }
    ;

vyraz:
    jednoduchy_vyraz  { $$ = $1; }
    | jednoduchy_vyraz RELOP jednoduchy_vyraz
        {
            char *t = new_temp();
            printf("%s = %s %s %s\n", t, $1, $2, $3);
            free($1); free($2); free($3);
            $$ = t;
        }
    ;

jednoduchy_vyraz:
    terminalni_vyraz  { $$ = $1; }
    | jednoduchy_vyraz '+' terminalni_vyraz
        {
            char *t = new_temp();
            printf("%s = %s + %s\n", t, $1, $3);
            free($1); free($3);
            $$ = t;
        }
    | jednoduchy_vyraz '-' terminalni_vyraz
        {
            char *t = new_temp();
            printf("%s = %s - %s\n", t, $1, $3);
            free($1); free($3);
            $$ = t;
        }
    | jednoduchy_vyraz OR_OP terminalni_vyraz
        {
            char *t = new_temp();
            printf("%s = %s | %s\n", t, $1, $3);
            free($1); free($3);
            $$ = t;
        }
    ;

terminalni_vyraz:
    faktor  { $$ = $1; }
    | terminalni_vyraz '*' faktor
        {
            char *t = new_temp();
            printf("%s = %s * %s\n", t, $1, $3);
            free($1); free($3);
            $$ = t;
        }
    | terminalni_vyraz '/' faktor
        {
            char *t = new_temp();
            printf("%s = %s / %s\n", t, $1, $3);
            free($1); free($3);
            $$ = t;
        }
    | terminalni_vyraz AND_OP faktor
        {
            char *t = new_temp();
            printf("%s = %s & %s\n", t, $1, $3);
            free($1); free($3);
            $$ = t;
        }
    | terminalni_vyraz DIV_OP faktor
        {
            char *t = new_temp();
            printf("%s = %s div %s\n", t, $1, $3);
            free($1); free($3);
            $$ = t;
        }
    | terminalni_vyraz MOD_OP faktor
        {
            char *t = new_temp();
            printf("%s = %s mod %s\n", t, $1, $3);
            free($1); free($3);
            $$ = t;
        }
    ;

faktor:
    ID           { $$ = $1; }
    | NUM        { $$ = $1; }
    | CHAR_CONST { $$ = $1; }
    | '(' vyraz ')' { $$ = $2; }
    | '-' faktor
        {
            char *t = new_temp();
            printf("%s = -%s\n", t, $2);
            free($2);
            $$ = t;
        }
    | NOT_OP faktor
        {
            char *t = new_temp();
            printf("%s = !%s\n", t, $2);
            free($2);
            $$ = t;
        }
    ;

%%

void yyerror(const char *s) {
    fprintf(stderr, "Syntakticka chyba na radku %d: %s\n", yylineno, s);
    exit(1);
}

int main(int argc, char **argv) {
    extern FILE *yyin;
    if (argc < 2) {
        fprintf(stderr, "Pouziti: %s <jmeno zdrojoveho souboru>\n", argv[0]);
        return 1;
    }
    yyin = fopen(argv[1], "r");
    if (!yyin) {
        perror(argv[1]);
        return 1;
    }
    yyparse();
    fclose(yyin);
    return 0;
}

%option noyywrap
%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "parser.h"
%}

white	[ \t\n]+
id	[_a-zA-Z][_a-zA-Z0-9]*
dec	&[0-9]+
hex	[0-9][0-9a-fA-F]*
comment \(\*([^*]+)?\*+([^*)][^*]*\*+)*\)

%%

"end"       return (END);
"return"    return (RETURN);
"goto"      return (GOTO);
"if"        return (IF);
"then"      return (THEN);
"var"       return (VAR);
"not"       return (NOT);
"and"       return (AND);
";"         return (';');
"("         return ('(');
")"         return (')');
","         return (',');
":"         return (':');
"="         return ('=');
"*"         return ('*');
"-"         return ('-');
"+"         return ('+');
"#"         return ('#');
"=<"        return (LESSEQ);
{dec}       return (NUM); @{ @NUM.name@=strdup(yytext); @}
{hex}       return (NUM); @{ @NUM.name@=strdup(yytext); @}
{id}		return (ID); @{ @ID.name@=strdup(yytext); @}
{white}
{comment}
.	{
	fprintf(stderr, "lexical error: unrecognized character \"%s\"\n", yytext);
	exit(1);
}

%%


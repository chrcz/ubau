%option noyywrap
%{
#include "parser.h"
/*flex includes standard libs (string.h, stdlib.h, stdio.h) for us*/
%}

white	[ \t\n]+
id		[_a-zA-Z][_a-zA-Z0-9]*
dec		&[0-9]+
hex		[0-9][0-9a-fA-F]*
comment	\(\*([^*]+)?\*+([^*)][^*]*\*+)*\)

%%

"end"		return (END);
"return"	return (RETURN);
"goto"		return (GOTO);
"if"		return (IF);
"then"		return (THEN);
"var"		return (VAR);
"not"		return (NOT);
"and"		return (AND);
";"			return (';');
"("			return ('(');
")"			return (')');
","			return (',');
":"			return (':');
"="			return ('=');
"*"			return ('*');
"-"			return ('-');
"+"			return ('+');
"#"			return ('#');
"=<"		return (LESSEQ);
{id}		return (ID);
{dec}		return NUM;
{hex}		return NUM;
{white}
{comment}
.	{
	fprintf(stderr, "error in scanner: unrecognized character \"%s\"\n", yytext);
	exit(1);
}

%%


%option noyywrap

/*no need to import standard libraries as flex does it anyway*/

key		"end"|"return"|"goto"|"if"|"then"|"var"|"not"|"and"
lexem	[;(),:=*\-+#]|"=<"
white	[ \t\n]+
ident	[_a-zA-Z][_a-zA-Z0-9]*
dec		&[0-9]+
hex		[0-9][0-9a-fA-F]*
comment	\(\*[^*]*\*+([^*)][^*]*\*+)*\)

%%

{white}

{comment}

{key}	|

{lexem}	printf("%s\n", yytext);

{ident}	printf("ident %s\n", yytext);

{hex}	printf("num %d\n", strtol(yytext, NULL, 16));

{dec}	{
			char *dest = strdup(yytext+1);
			printf("num %d\n", strtol(dest, NULL, 10));
		}

.		{
			fprintf(stderr, "unrecognized character \"%s\"\n", yytext);
			exit(1);
		}

%%

main(int argc, char **argv){
	yylex();
}


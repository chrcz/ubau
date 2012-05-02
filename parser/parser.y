%{
#include "scanner.h"
#include "parser.h"
/*flex includes standard libs (string.h, stdlib.h, stdio.h) for us*/
%}

%error-verbose
%start program
%token END RETURN GOTO IF THEN VAR NOT AND ID NUM LESSEQ

%%

program:	/*empty*/
		| funcdef ';' program
		;

funcdef:	ID '(' pars ')' stats END
		;

pars:		/*empty*/
		| ID
		| ID ',' pars
		;

stats:		/*empty*/
		| stats stuff ';'
		;

stuff:		labeldefs stat 
		;

labeldefs:	/*empty*/
		| labeldefs ID ':'
		;

stat:		RETURN expr
		| GOTO ID
		| IF expr THEN stats END
		| VAR ID '=' expr
		| lexpr '=' expr
		| term
		;

lexpr:		ID
		| '*' unary
		;

expr:		unary
		| addop
		| mulop
		| andop
		| term LESSEQ term
		| term '#' term
		;

unary:		NOT unary
		| '-' unary
		| '*' unary
		| term
		;

term:		'(' expr ')'
		| NUM
		| ID
		| ID '(' exprs ')'
		;

exprs:		/*empty*/
		| expr
		| expr ',' exprs
		;

addop:		term '+' term
		| addop '+' term
		;

mulop:		term '*' term
		| mulop '*' term
		;

andop:		term AND term
		| andop AND term
		;

%%

int main(void){
	#if YYDEBUG
		yydebug=1;
	#endif
	return yyparse();
}

int yyerror(char *s){
	fprintf(stderr, "error in parser: %s\n", s);
	exit(2);
}

%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "parser.h"
#include "gs_list.h"
%}

%start program
%token END RETURN GOTO IF THEN VAR NOT AND ID NUM LESSEQ

@autoinh varinh lblinh
@autosyn lblsyn parsyn varsyn

@attributes { char *name; } ID
@attributes { struct gs_head *parsyn; } pars parstart
@attributes { struct gs_head *lblsyn, *lblinh, *varinh, *varsyn; } stats 
@attributes { struct gs_head *lblsyn, *lblinh, *varinh; } ifstat
@attributes { struct gs_head *lblsyn; } labeldef 
@attributes { struct gs_head *varinh; } stdstat lexpr expr term unary exprs exprstart addop mulop andop

@traversal @preorder LRpre
/*@traversal LRpost /*lefttoright and postorder by default*/

%%

program:	/*empty*/
			| program funcdef ';'
			;

funcdef:	ID '(' pars ')' stats END
				@{	@i	@stats.lblinh@ = @stats.lblsyn@;
					@i	@stats.varinh@ = copy_merge(@pars.parsyn@, @stats.varsyn@);

					@LRpre	printf("parameters of %s: ", @ID.name@);
							printlist(@pars.parsyn@); 
							if(has_duplicates(@pars.parsyn@)){
								printf("duplicate parameter\n");
								exit(3);
							}
							printf("labels of %s: ", @ID.name@);
							printlist(@stats.lblsyn@); 
							if(has_duplicates(@stats.lblsyn@)){
								printf("duplicate label\n");
								exit(3);
							}
							if(!distinct(@stats.varinh@, @stats.lblsyn@)){
								printf("variables and labels not distinct\n");
								exit(3);
							}
							if(!distinct(@stats.varsyn@, @pars.parsyn@)){
								printf("variables and labels not distinct\n");
								exit(3);
							}
				@}
			;

pars:		parstart /*autosyn parsyn*/
			| parstart ID
				@{ @i @pars.parsyn@ = add_symbol(@parstart.parsyn@, @ID.name@); @}
			;

parstart:	/*empty*/
				@{ @i @parstart.parsyn@ = NULL; @}
			| parstart ID ','
				@{ @i @parstart.0.parsyn@ = add_symbol(@parstart.1.parsyn@, @ID.name@); @}
			;

labeldef:	/*empty*/
				@{ @i @labeldef.lblsyn@ = NULL; @}
			| labeldef ID ':'
				@{ @i @labeldef.0.lblsyn@ = add_symbol(@labeldef.1.lblsyn@, @ID.name@); @}
			;

stats:		/*empty*/
				@{	@i	@stats.lblsyn@ = NULL;
					@i	@stats.varsyn@ = NULL;

				@}
			| stats labeldef GOTO ID ';'
				@{	@i	@stats.0.lblsyn@ = merge(@labeldef.lblsyn@, @stats.1.lblsyn@);

					@LRpre	if(!has_symbol(@stats.0.lblinh@, @ID.name@)){
								printf("label %s not visible\n", @ID.name@);
								exit(3);
							}
				@}
			| stats labeldef stdstat ';'
				@{	@i	@stats.0.lblsyn@ = merge(@labeldef.lblsyn@, @stats.1.lblsyn@);

				@}
			| stats labeldef VAR ID '=' expr ';'
				@{	@i	@stats.0.lblsyn@ = merge(@labeldef.lblsyn@, @stats.1.lblsyn@);
					@i	@stats.0.varsyn@ = add_symbol(@stats.1.varsyn@, @ID.name@);

					@LRpre	
							if(has_duplicates(@stats.0.varsyn@)){
								printf("multiple definitions of variable %s\n", @ID.name@);
								exit(3);
							}
							if(has_symbol(@stats.0.lblsyn@, @ID.name@)){
								printf("label and variable not distinct: %s\n", @ID.name@);
								exit(3);
							}
				@}
			| stats labeldef IF expr THEN stats END ';'
				@{	@i	@stats.0.lblsyn@ = merge(@labeldef.lblsyn@, merge(@stats.1.lblsyn@, @stats.2.lblsyn@));
					@i	@stats.0.varsyn@ = @stats.1.varsyn@;
					@i	@stats.2.varinh@ = copy_merge(@stats.0.varinh@, @stats.2.varsyn@);

					@LRpre
						if(has_duplicates(@stats.2.varinh@)){
							exit(3);
						}
				@}
			;

stdstat:	RETURN expr
			| lexpr '=' expr
			| term
			;

lexpr:		ID
				@{	@LRpre	if(!has_symbol(@lexpr.varinh@, @ID.name@)){
							printlist(@lexpr.varinh@);
							printf("variable %s not visible in lexpr\n", @ID.name@);
							exit(3);
						}
				@}
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
			;	/*only here we have right recursion (well, also in ifstat actually)*/

term:		'(' expr ')'
			| NUM
			| ID
				@{	@LRpre	if(!has_symbol(@term.varinh@, @ID.name@)){
							printf("variable %s not visible in term\n", @ID.name@);
							exit(3);
						}
				@}
			| ID '(' exprs ')'
			;

exprs:		exprstart
			| exprstart expr
			;

exprstart:	/*empty*/
			| exprstart expr ','
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
	int i = yyparse();
	if(i==0){
		printf("valid program\n");
	}
	return i;
}

int yyerror(char *s){
	fprintf(stderr, "error in parser: %s\n", s);
	exit(2);
}

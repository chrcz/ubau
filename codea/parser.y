%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "parser.h"
#include "gs_list.h"
#include "tree.h"
%}

%start program
%token END RETURN GOTO IF THEN VAR NOT AND ID NUM LESSEQ

@autoinh varinh lblinh
@autosyn lblsyn parsyn varsyn node

@attributes { char *name; } ID NUM
@attributes { struct gs_head *parsyn; } pars parstart
@attributes { struct gs_head *lblsyn, *lblinh, *varinh, *varsyn; } stats 
@attributes { struct gs_head *lblsyn, *lblinh, *varinh; } ifstat
@attributes { struct gs_head *lblsyn; } labeldef 
@attributes { struct gs_head *varinh; } stdstat lexpr exprs exprstart
@attributes { struct gs_head *varinh; struct t_node *node; } expr term unary addop mulop andop returnstat

@traversal @preorder CHECK 
@traversal @preorder CODEGEN

%%

program:	/*empty*/
			| program funcdef ';'
			;

funcdef:	ID '(' pars ')' stats END
				@{	@i	@stats.lblinh@ = @stats.lblsyn@;
					@i	@stats.varinh@ = copy_merge(@pars.parsyn@, @stats.varsyn@);

					@CHECK
					/*printf("parameters of %s: ", @ID.name@);
					printlist(@pars.parsyn@); */
					if(has_duplicates(@pars.parsyn@)){
						printf("duplicate parameter\n");
						exit(3);
					}
/*					printf("labels of %s: ", @ID.name@);
					printlist(@stats.lblsyn@); */
					if(has_duplicates(@stats.lblsyn@)){
						printf("duplicate label\n");
						exit(3);
					}
					if(!distinct(@stats.varinh@, @stats.lblsyn@)){
						printf("variables and labels not distinct\n");
						exit(3);
					}

					@CODEGEN
					
					print_header(@ID.name@);
				@}
			;

/*pars.parsyn has a list of correct order.*/

pars:		parstart
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

					@CHECK
					if(!has_symbol(@stats.0.lblinh@, @ID.name@)){
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

					@CHECK	
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

					@CHECK
					if(has_duplicates(@stats.2.varinh@)){
						exit(3);
					}
				@}
			| stats labeldef returnstat ';'
				@{	@i	@stats.0.lblsyn@ = merge(@labeldef.lblsyn@, @stats.1.lblsyn@); @}
			;

returnstat	: RETURN expr
				@{	@i	@returnstat.node@ = new_node(RET_OP, @expr.node@, NULL, NULL);

					@CODEGEN
					burm_label(@returnstat.node@);
					burm_reduce(@returnstat.node@,1);
				@}
			;

stdstat:	lexpr '=' expr
			| term
			;

lexpr:		ID
				@{	@CHECK
					if(!has_symbol(@lexpr.varinh@, @ID.name@)){
						printlist(@lexpr.varinh@);
						printf("variable %s not visible in lexpr\n", @ID.name@);
						exit(3);
					}
				@}
			| '*' unary
			;

/*autosyn node*/

expr:		unary
			| addop
			| mulop
			| andop
			| term LESSEQ term
				@{ @i	@expr.node@ = new_node(LEQ_OP, @term.0.node@, @term.1.node@, NULL); @}
			| term '#' term
				@{ @i	@expr.node@ = new_node(NEQ_OP, @term.0.node@, @term.1.node@, NULL); @}
			;

/*only here we have right recursion (well, also in ifstat actually)*/

unary		: NOT unary
				@{ @i	@unary.0.node@ = new_node(NOT_OP, @unary.1.node@, NULL, NULL); @}
			| '-' unary
				@{ @i	@unary.0.node@ = new_node(NOT_OP, @unary.1.node@, NULL, NULL); @}
			| '*' unary
				@{ @i	@unary.0.node@ = new_node(NOT_OP, @unary.1.node@, NULL, NULL); @}
			| term
			;

term:		'(' expr ')'
			| NUM
				@{ @i	@term.node@ = new_node(CON_OP, NULL, NULL, @NUM.name@); @}
			| ID
				@{	@i	@term.node@ = new_node(VAR_OP, NULL, NULL, @ID.name@);
					
					@CHECK
					if(!has_symbol(@term.varinh@, @ID.name@)){
						printf("variable %s not visible in expression\n", @ID.name@);
						exit(3);
					}
				@}
			| ID '(' exprs ')'
				@{ @i @term.node@ = NULL; @}
			;

addop:		term '+' term
				@{ @i	@addop.node@ = new_node(ADD_OP, @term.0.node@, @term.1.node@, NULL); @}
			| addop '+' term
				@{ @i	@addop.0.node@ = new_node(ADD_OP, @addop.1.node@, @term.node@, NULL); @}
			;

mulop:		term '*' term
				@{ @i	@mulop.node@ = new_node(MUL_OP, @term.0.node@, @term.1.node@, NULL); @}
			| mulop '*' term
				@{ @i	@mulop.0.node@ = new_node(MUL_OP, @mulop.1.node@, @term.node@, NULL); @}
			;

andop:		term AND term
				@{ @i	@andop.node@ = new_node(AND_OP, @term.0.node@, @term.1.node@, NULL); @}
			| andop AND term
				@{ @i	@andop.0.node@ = new_node(AND_OP, @andop.1.node@, @term.node@, NULL); @}
			;

exprs:		exprstart
			| exprstart expr
			;

exprstart:	/*empty*/
			| exprstart expr ','
			;

%%

int main(void){
	#if YYDEBUG
		yydebug=1;
	#endif
	int i = yyparse();
	if(i==0){
	/*	printf("valid program\n");*/
	}
	return i;
}

int yyerror(char *s){
	fprintf(stderr, "%s\n", s);
	exit(2);
}

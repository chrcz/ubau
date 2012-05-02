#include <stdio.h>
#include "codegen.h"

void print_header(char *id){
	printf(".globl %s\n.type %s, @function\n\n%s:\n",id,id,id);
}


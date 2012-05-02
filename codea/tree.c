#include <stdlib.h>
#include "tree.h"

struct t_node *new_node(int op, struct t_node *left, struct t_node *right, char *value){
	struct t_node *new = malloc(sizeof(struct t_node));
	new->op = op;
	new->kids[0] = left;
	new->kids[1] = right;
	switch (op){
	case CON_OP:
		new->value = (*value == '&') ? strtol(value+1, NULL, 10) : strtol(value, NULL, 16);
		break;
	case VAR_OP:
		new->name = value;
		break;
	}
	return new;
}

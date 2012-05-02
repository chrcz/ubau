#ifndef TREE_H_
#define TREE_H_

#define NODEPTR_TYPE	struct t_node *
#define OP_LABEL(p)		((p)->op)
#define STATE_LABEL(p)	((p)->state)
#define LEFT_CHILD(p)	((p)->kids[0])
#define RIGHT_CHILD(p)	((p)->kids[1])
#define PANIC			printf

enum{
	ADD_OP=1,	/* addition */
	MUL_OP,		/* multiplication */
	AND_OP,		/* logical "and" */
	LEQ_OP,		/* '=<' less or equal */
	NEQ_OP,		/* '#' not equal */
	NOT_OP,		/* logical "not" */
	NEG_OP,		/* '-' unary minus */
	PTR_OP,		/* '*' unary star, pointer */
	RET_OP,		/* "return" */
	CON_OP,		/* a constant */
	VAR_OP		/* a variable */
};

struct t_node{
	int op;
	struct burm_state *state;
	struct t_node *kids[2];
	char *name;
	long value;
};

struct t_node *new_node(int operator, struct t_node *left, struct t_node *right, char *value);

#endif

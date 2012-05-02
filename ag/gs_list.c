#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include "gs_list.h"

struct gs_head *add_symbol(struct gs_head *head, const char *name){
	struct gs_elem *new = malloc(sizeof(struct gs_elem));
	new->name = name;
	new->next = NULL;
	new->head = head;

	if(head == NULL){
		head = malloc(sizeof(struct gs_head));
		head->first = head->last = new;
	}else{
		head->last->next = new;
		head->last = new;
	}

	return head;
}

struct gs_head *add_symbol_copy(struct gs_head *head, const char *name){
	struct gs_head *copy = copy_head(head);
	return add_symbol(copy, name);
}

int has_duplicates(const struct gs_head *head){
	if(head == NULL || head->first == NULL){
		return 0;
	}
	struct gs_elem *e = head->first;
	struct gs_elem *comp;
	while(e != NULL){
		comp = e->next;
		while(comp != NULL){
			/*printf("comparing %s to %s\n",e->name,comp->name);*/
			if(strcmp(e->name, comp->name) == 0){
				printf("duplicate found: %s (maybe more)\n",e->name);
				return 1;
			}
			comp = comp->next;
		}
		e = e->next;
	}
	return 0;
}

struct gs_elem *copy_elem(const struct gs_elem *elem, struct gs_head *newhead){
	if(elem == NULL){
		return NULL;
	}else{
		struct gs_elem *new = malloc(sizeof(struct gs_elem));
		new->head = newhead;
		new->name = strdup(elem->name);
		new->next = copy_elem(elem->next, newhead);
		return new;
	}
}

struct gs_head *copy_head(const struct gs_head *head){
	if(head == NULL){
		return NULL;
	}else{
		struct gs_head *newhead = malloc(sizeof(struct gs_head));
		newhead->first = copy_elem(head->first, newhead);
		struct gs_elem *e = newhead->first;
		while(e->next != NULL){
			e = e->next;
		}
		newhead->last = e;
		return newhead;
	}
}

struct gs_head *copy_merge(struct gs_head *one, struct gs_head *two){
	struct gs_head *copy_one = copy_head(one);
	struct gs_head *copy_two = copy_head(two);

/*	printf("one: ");
	printlist(one);
	printf(" copy_one: ");
	printlist(copy_one);
	printf("two: ");
	printlist(two);
	printf(" copy_two: ");
	printlist(copy_two);		*/

	return merge(copy_one, copy_two);
}

struct gs_head *merge(struct gs_head *one, struct gs_head *two){
	if(one == NULL){
		one = two;
	}else if(two != NULL){
		if(one->last == NULL || one->first == NULL){
			one->first = two->first;
			one->last = two->last;
		}else{
			one->last->next = two->first;
		}
	}
	two = one;
	return one;
}

int distinct(const struct gs_head *one, const struct gs_head *two){
	if(one == NULL || two == NULL){
		return 1;
	}
	struct gs_elem *e = one->first;
	while(e != NULL){
		if(has_symbol(two, e->name)){
			return 0;
		}
		e = e->next;
	}
	return 1;
}

int has_symbol(const struct gs_head *head, const char *name){
	if(head == NULL){
		return 0;
	}
	struct gs_elem *e = head->first;
	while(e != NULL){
		if(strcmp(e->name, name) == 0){
			return 1;
		}
		e = e->next;
	}
	return 0;
}

void printlist(struct gs_head *head){
	if(head == NULL){
		printf("<empty>\n");
		return;
	}
	struct gs_elem *e = head->first;
	while(e != NULL){
		printf("%s,",e->name);
		e = e->next;
	}
	printf("\n");
}

char *tostring(const struct gs_head *head, int printsize){
    char *s = malloc(sizeof(char)*100);
    int i = 0;
    char *c = malloc(sizeof(char));

	if(head == NULL || head->first == NULL){
		sprintf(s, "<empty>");
		return s;
	}

    struct gs_elem *e = head->first;
    while(e != NULL){
        strncat(s, e->name, strlen(e->name));
        strncat(s, " ", 1);
        i++;
        e = e->next;
    }
	if(printsize){
		sprintf(c,"%d",i);
	    strncat(s, c, 2);
	}
       return s;
}


struct gs_head{
	struct gs_elem *first, *last;
};

struct gs_elem{
	const char *name;
	struct gs_elem *next;	
	struct gs_head *head;
};

/************ APPENDING AND MERGING *************/

/*Appends name to list and returns head. Creates a new gs_head if head is NULL.*/
struct gs_head *add_symbol(struct gs_head *head, const char *name);

struct gs_head *add_symbol_copy(struct gs_head *head, const char *name);

/*Recursively copies the element and all of its successors. Returns the first element or NULL if it is null.*/
struct gs_elem *copy_elem(const struct gs_elem *elem, struct gs_head *newhead);

/*Copies a list.*/
struct gs_head *copy_head(const struct gs_head *head);

/*Makes a deep copy of the lists and then behaves like merge on the copies. Therefore the original lists remain untouched.*/
struct gs_head *copy_merge(struct gs_head *one, struct gs_head *two);

/*Appends two to one and returns one. Returns NULL if both are null. Modifies the lists.*/
struct gs_head *merge(struct gs_head *one, struct gs_head *two);

/************ TESTING *************/

/*Returns 1 if any list is NULL or if a merge would contain no duplicates. Otherwise 0.*/
int distinct(const struct gs_head *one, const struct gs_head *two);

/*Returns 0 for NULL list or a list of unique items. Returns 1 otherwise.*/
int has_duplicates(const struct gs_head *head);

/*Returns 0 for a NULL list or a list which does not contain name. Returns 1 otherwise.*/
int has_symbol(const struct gs_head *head, const char *name);

/************ PRINTING *************/

/*Prints the list to stdout from first to last.*/
void printlist(struct gs_head *head);

char *tostring(const struct gs_head *head, int printsize);


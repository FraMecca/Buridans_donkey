#include <stdio.h>
#include <math.h>
#include <sys/poll.h>
#include <limits.h>
#include <sys/syscall.h>
#include <unistd.h>
#include <linux/random.h>
#include <stdlib.h>
#include <string.h>

#define MAX_L 1000

struct arg {
	char *str;
	struct arg *next;
	struct arg *prev;
	int idx;
}; 

int
check_pipe()
{
	struct pollfd fds;
	int ret;

	fds.fd = STDIN_FILENO; //stdin file descriptor (0)
	fds.events = POLLIN;
	ret = poll(&fds, 1, 0);
	return ret;
}

struct arg*
new_arg(void)
{
	struct arg *a;

	if(!(a = malloc(sizeof(struct arg)))){
		fprintf(stderr, "Allocation error.\n");
		exit(EXIT_FAILURE);
	}
	a->prev = NULL;
	a->next = NULL;

	return a;
}

struct arg*
push_arg(struct arg* a, struct arg *args)
{
	a->prev = args;
	args->next = a;
	return a;
}

int
load_arguments(struct arg *args, int idx, char **argv, int argc, struct arg **head)
{ 
	// head is passed and stores the head to the pipeArgs struct
	char buf[MAX_L];
	struct arg *newA;

	if (argc == 1 && check_pipe () == 1) {
		// load from poll
		if (fgets(buf, MAX_L, stdin) == NULL) {
			return idx;
		}
		if(buf[strlen(buf) - 1] == '\n'){
			buf[strlen(buf) - 1] = '\0';
		}
	} else { // load argv
		if (argc == idx + 1) {
			// got all the arguments
			return idx;
		}
		strcpy (buf, argv[idx + 1]);
	}
	newA = new_arg();
	newA->str = strdup(buf);
	
	if(args == NULL){
		args = newA;
		*head = args;
		args->idx = idx;
	} else {
		args = push_arg(newA, args);	
		args->idx = idx; // should pass index on push_arg
	}
	return load_arguments(args, idx +1, argv, argc, head);
}

int
get_randN(void)
{
	int seed;

	syscall(SYS_getrandom, &seed, sizeof(int), GRND_NONBLOCK);
	return abs(seed);
}


int
check_alloc(char *a)
{
	if(!a){
		return 1;
	}
	return 0;
}

struct arg *
get_element_node (struct arg *a, int idx)
{
	while (idx != a->idx) {
		a = a->next;
	}
	return a;
}

void
swap_elements (struct arg **elements, int x, int y)
{
	char *strX, *strY;
	struct arg *eX, *eY;

	/*strX = get_element_str (elements[0], x);*/
	/*strY = get_element_str (elements[0], y);*/
	eX = get_element_node (elements[0], x);
	eY = get_element_node (elements[0], y);
	
	strX = strdup (eX->str);
	strY = strdup (eY->str);


	// start swap
	free (eX->str);
	eX->str = strdup (strY);
	free (eY->str);
	eY->str = strdup (strX);

	free (strX);
	free (strY);
}

struct arg *
shuffle_elements(struct arg *elements, int nElements)
{
	int i, j;
	double randN;
	
	for(i=nElements-1; i>0; i--){
		randN = (double) get_randN()/(INT_MAX/(i)) ;
		j = round(randN);
		
		if(i != j){
			swap_elements (&elements, i, j);
		}
	}
	return elements;
}

void
print_elements(struct arg *elements, int nElements)
{ 
	while (elements != NULL) {
		printf ("%d. %s\n", elements->idx + 1, elements->str);
		elements = elements->next;
	}
}

void
free_elements (struct arg *ptr, int n)
{
	struct arg *tmp;
	while (ptr != NULL) {
		tmp = ptr;
		ptr = ptr->next; // :^)
		free (tmp->str);
		free (tmp);
	}
}

/*struct cli_t {*/
	/*int argc;*/
	/*char **argv;*/
/*};*/

int
main(int argc, char *argv[])
{
	int nElements;
	struct arg *elements = NULL, *head = NULL;
	/*struct cli_t cli;*/

	/* 
	 * always pass head
	 * prev is next and next is prev
	 * kill me now
	 *
	 */

	/*cli = parse_args (argc, argv);*/
	
	//check argv
	nElements = load_arguments(elements, 0, argv, argc, &head); // recursive polling
	// now head stores the beginning of the list

	if((head = shuffle_elements(head, nElements))){
		print_elements(head, nElements);
		free_elements (head, nElements);
	}

	return 0;
}

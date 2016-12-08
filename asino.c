/*   Asino, order a list of strings randomly
 *
 *	 Copyright (C) 2016	Francesco Mecca
 *
 *	This program is free software: you can redistribute it and/or modify
 *	it under the terms of the GNU General Public License as published by
 *	the Free Software Foundation, either version 3 of the License, or
 *	(at your option) any later version.
 *
 *	This program is distributed in the hope that it will be useful,
 *	 but WITHOUT ANY WARRANTY; without even the implied warranty of
 *	 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *	 GNU General Public License for more details.
 *
 *	 You should have received a copy of the GNU General Public License
 *	 along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#include <stdio.h>
#include <math.h>
#include <sys/poll.h>
#include <limits.h>
#include <sys/syscall.h>
#include <unistd.h>
#include <linux/random.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>

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
get_randN(bool randFlag)
{
	int seed;

	syscall(SYS_getrandom, &seed, sizeof(int), randFlag);
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
shuffle_elements(struct arg *elements, int nElements, bool randFlag)
{
	int i, j;
	double randN;
	
	for(i=nElements-1; i>0; i--){
		randN = (double) get_randN(randFlag)/(INT_MAX/(i)) ;
		j = round(randN);
		
		if(i != j){
			swap_elements (&elements, i, j);
		}
	}
	return elements;
}

void
print_elements(struct arg *elements, bool numbFlag)
{ 
	while (elements != NULL) {
		if (numbFlag == true) {
			printf ("%d. ", elements->idx + 1);
		}
		printf ("%s\n", elements->str);
		elements = elements->next;
	}
}

void
free_elements (struct arg *ptr)
{
	struct arg *tmp;
	while (ptr != NULL) {
		tmp = ptr;
		ptr = ptr->next; // :^)
		free (tmp->str);
		free (tmp);
	}
}

struct cli_t {
	int argc;
	char **argv;
	bool random;
	bool numbers;
};

struct cli_t
parse_args (const int argc, char ** argv)
{
	/*
	 * this function parses the args
	 * return cli_t struct that contains all the flags used
	 * parameters:
	 * --urandom, -u: no arguments, uses /dev/urandom instead of /dev/random
	 * --no-numbers, -n: no arguments, disable line numbers
	 */
	int i, pos = 1;
	struct cli_t cli;

	cli.random = GRND_NONBLOCK;
	cli.numbers = true;
	cli.argc = argc;
	cli.argv = calloc (argc ,  sizeof (char *));

	for (i = 1; i < argc; ++i) {
		if (argv[i][0] == '-') {
			switch (argv[i][1]) {
				case 'n':
					cli.numbers = false;
					cli.argc--;
					break;
				case 'u':
					cli.random = GRND_RANDOM;
					cli.argc--;
				default:
					// long options
					if (strcmp (argv[i], "--no-numbers") == 0) {
						cli.numbers = false;
						cli.argc--;
					} else if (strcmp (argv[i], "--urandom") == 0) {
						cli.random = GRND_RANDOM;
						cli.argc--;
					}
			}
		} else {
			cli.argv[pos] = strdup (argv[i]);
			pos++;
		}
	}
		
	return cli;
}

void
free_cli (struct cli_t cli)
{
	int i;
	for (i = 0; i < cli.argc; ++i) {
		if (cli.argv[i] != NULL) {
			free (cli.argv[i]);
		}
	}
	free (cli.argv);
}


int
main(int argc, char *argv[])
{
	int nElements;
	struct arg *elements = NULL, *head = NULL;
	struct cli_t cli;

	cli = parse_args (argc, argv);
	
	//check argv
	nElements = load_arguments(elements, 0, cli.argv, cli.argc, &head); // recursive polling
	// now head stores the beginning of the list

	if((head = shuffle_elements(head, nElements, cli.random))){
		print_elements(head, cli.numbers);
		free_elements (head);
	}
	free_cli (cli);

	return 0;
}

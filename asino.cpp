#include <iostream>
#include <vector>
#include <algorithm>
#include <random>
#include <string>
#include <sys/poll.h>
using namespace std;

struct pollfd stdin_poll = {
    .fd = fileno (stdin), .events = POLLIN
};

void read_from_piped_input (vector<string>& lst)
{
    string x;
    while (getline (cin, x)) {
        lst.push_back (x);
    }
}

void read_from_arguments (const int& argc, char* argv[], vector<string>& lst)
{
    if (argc  == 1) {
        cout << "Usage: asino [string] [string] ..." << endl;
        exit;
    }
    for (vector<string>::size_type i = 1; i < argc; ++i) {
        lst.push_back (argv[i]);
    }
}

int main (int argc, char* argv[])
{
    vector<string> lst;
    int poll_ret = poll (&stdin_poll, 1, 0);
    if (poll_ret > 0) {
        read_from_piped_input (lst);
    }
    else {
    read_from_arguments (argc, argv, lst);
    }

    random_device rd;
    mt19937 m(rd());
    shuffle (lst.begin (), lst.end (), m);
    
	int i = 1;
    for (vector<string>::iterator it = lst.begin (); it != lst.end (); ++it) {
        cout << i++ << ". " << *it << endl;
    }
}

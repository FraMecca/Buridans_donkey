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

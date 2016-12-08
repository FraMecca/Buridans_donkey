#!/usr/bin/python3

# Asino, order a list of strings randomly
# Copyright (C) 2016	Francesco Mecca

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

import random

def parse_args ():
    import argparse
    parser = argparse.ArgumentParser ()
    parser.add_argument ('-n', '--no-numbers', action = 'store_true', default = False,
                         help = 'do not display line numbers')
    parser.add_argument ('choices', type = str, nargs= '*', default = [],
                         help = 'where the various choices belong')
    parser.add_argument ('-l', '--limit', type = int, default = False,
                         help = 'display n lines')
    return parser.parse_args ()

_cnt = -1
def enum ():
    global _cnt
    _cnt += 1
    return (''.join ([str (_cnt), '. ']))
def null_string ():
    return ''

def main ():
    from sys import stdin
    args = parse_args ()

    if args.limit:
        limit = args.limit - 2
    if args.no_numbers:
        fst = null_string
    else:
        fst = enum

    if not stdin.isatty():
        for line in stdin:
            if line[-1] is '\n':
                line = line[:-1]
            args.choices.append(line)

    argRange = len(args.choices)
    for i in range (argRange):
        print (''.join ([fst (), args.choices.pop(random.randrange(0, len(args.choices)))]))
        if args.limit and i > limit:
            exit ()


if __name__ == '__main__':
    main ()

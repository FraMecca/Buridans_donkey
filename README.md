# Buridan_donkey
Written in c++, c and python, this program given some choices orders them in casual order.
More info at: http://francescomecca.eu/index.php/archives/207

# C

The C version is the most complete. It makes a system call to get a random pool of numbers.

Compile including math library.

It supports cli arguments:

```
	  --urandom, -u: no arguments, uses /dev/urandom instead of /dev/random
	  --no-numbers, -n: no arguments, disable line numbers
```

# Example

```
$ ls

asino.c  asino.cpp  asino.py  README.md

$ ls | asino

1. asino.c
2. README.md
3. asino.py
4. asino.cpp

```

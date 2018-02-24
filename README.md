# Buridan's donkey
Originally written in c++ and python, this program given some choices orders them in casual order. 
I wrote about it at: http://francescomecca.eu/index.php/archives/207

Now I rewrite the Buridan's donkey in whatever language I feel passionate about.

# D

The D version is the most complete and provides the following options:

	-n --numbers enable number output on screen
	-d --divider divide the arguments using a different divider
	-v --version show version and exit
	-e  --engine Choose the RNG between "mt" (Mersenne-Twister, default), "x" (xorshift),
					"dr" (/dev/random), "du" (/dev/urandom)
	
The program can also be used piped to another process.

	$ echo D C++ | ./asino -d " " -n 1
	1. D
	2. C++


# C

The C version makes a system call to get a random pool of numbers.

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

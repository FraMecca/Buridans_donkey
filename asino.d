/**
	Buridan's Donkey, Asino.
    Copyright: Francesco Mecca
	License: GPLv3
	Author: Francesco Mecca
*/
module asino;

import std.random;
import std.getopt;

import std.stdio : writeln, writefln, stdin;
import std.file : read;
import std.typecons : Yes, No;
import std.array : join, array;
import std.algorithm : splitter;

extern(C)
{
	struct pollfd { int   fd; short events; short revents; }
	int poll(pollfd *fds, int nfds, int timeout);
}

enum VERSION = "0.0.1";
string versionSt = "...a man, being just as hungry as thirsty,
and placed in between food and drink,
must necessarily remain where he is and starve to death
Aristole\n\n"~"asino "~VERSION;

void
main (string[] args)
{
	bool num, v;
	string engine = "mt";
	string div;
	auto cliOpts = getopt(
			args,
			"numbers|n", "enable number output on screen", &num,
			"divider|d", "divide the arguments using a different divider", &div,
			"version|v", "show version and exit", &v,
			"engine|e", "Choose the RNG between \"mt\" (Mersenne-Twister, default), \"x\" (xorshift),
				\"dr\" (/dev/random), \"du\" (/dev/urandom)", &engine
			);

    if(cliOpts.helpWanted){
     	defaultGetoptPrinter("Buridan's Donkey\nSort a list of strings randomly", cliOpts.options);
     	return;
 	} else if(v){
 		writeln(versionSt);
 	}

	string[] lines = void;
    if(isaTTY()){
        // read stdin, ignore cli args
		auto p = stdin.byLineCopy(No.keepTerminator).array();
        writeln(p[2]);
        lines = p;
	} else {
		lines = args[1 .. $]; // remove program name
	}

	auto res = lines.divide(div).shuffle(engine);

	foreach (i, arg; res) {
		if (!num) writeln(arg);
		else writefln("%s: %s", i + 1, arg);
	}
}

string[] divide(string[] args, string div)
{
	if (div == "") return args;
	else return args.join.splitter(div).array;
}

string[] shuffle(string[] args, string t)
{
	if(t == "mt"){
		Mt19937 gen;
		gen.seed(unpredictableSeed);
		args.randomShuffle(gen);
	} else if (t == "x"){
		Xorshift32 gen;
		gen.seed(unpredictableSeed);
		args.randomShuffle(gen);
	} else if (t == "du"){
		auto gen = DevRandomGen!"/dev/urandom"();
		args.randomShuffle(gen);
	} else if (t == "dr"){
		auto gen = DevRandomGen!"/dev/random"();
		args.randomShuffle(gen);
	} else {
		throw new Exception("Wrong arguments");
	}
	return args;
}


template DevRandomGen(string gen)
	if (gen == "/dev/random" || gen == "/dev/urandom")
{
	struct DevRandomGen
	{

		alias UIntType = uint;
  	  public:
    	enum bool isUniformRandom = true;
    	enum empty = false;
    	/// Smallest generated value.
    	enum UIntType min = 0;
    	/// Largest generated value.
    	enum UIntType max = ubyte.max;
    	string src = gen;

    	void seed(UIntType x0) @safe pure nothrow @nogc {}
    	void popFront() @safe pure nothrow @nogc {}

    	@property
    	UIntType front() const { return (cast(ubyte[])(src.read(ubyte.sizeof)))[0]; }

    	@property
    	typeof(this) save() @safe pure nothrow @nogc { return this; }
	}
}

bool isaTTY()
{
	pollfd fds;
	int ret;

	fds.fd = 0;
	fds.events = 0;
	ret = poll(&fds, 1, 0);
	return ret > 0;
}

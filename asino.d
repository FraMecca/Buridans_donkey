/**
	Buridan's Donkey, Asino.

	...a man, being just as hungry as thirsty, 
	and placed in between food and drink, 
	must necessarily remain where he is and starve to death.

	- Aristole

    Copyright: Francesco Mecca
	License: GPLv3
	Author: Francesco Mecca
*/
module asino;

import std.stdio;
import std.random;
import std.getopt;
import std.file;
import std.conv;

void
main (string[] args)
{
	bool num = false;
	string engine = "mt";
	auto cliOpts = getopt(
			args,
			"numbers|n", "enable number output on screen", &num,
			"engine|e", "Choose the RNG between \"mt\" (Mersenne-Twister, default), \"x\" (xorshift),
				\"dr\" (/dev/random), \"du\" (/dev/urandom)", &engine
			);

    if (cliOpts.helpWanted){
     	defaultGetoptPrinter("Buridan's Donkey", cliOpts.options);
     	return;
 	}

	args = args[1 .. $]; // remove program name
	args.shuffle(engine);
	//writeln(typeid(gen));

	foreach (i, arg; args) {
		if (!num) writeln(arg);
		else writefln("%s: %s", i, arg);
	}
}

void shuffle(ref string[] args, string t)
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


		/**
	  	  * Unused for /dev/random
	  	  */
    	void seed(UIntType x0) @safe pure nothrow @nogc {}


    	/**
     	 * Returns the current number in the random sequence.
     	 */
    	@property
    	UIntType front() const// @safe pure nothrow @nogc
    	{
        	//auto a = to!UIntType("/dev/random".read(UIntType.sizeof));
        	//return to!UIntType(a);
			return (cast(ubyte[])(src.read(ubyte.sizeof)))[0];
    	}


    	/**
     	 * Advances the random sequence.
     	 */
    	void popFront() @safe pure nothrow @nogc {}


    	/**
     	 * Captures a range state.
     	 */
    	@property
    	typeof(this) save() @safe pure nothrow @nogc
    	{
        	return this;
    	}
	}
}

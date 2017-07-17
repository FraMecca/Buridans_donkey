import std.stdio;
import std.random;
import std.getopt;

void
main (string[] args)
{
	bool num;
	auto cliOpts = getopt (
			args,
			"no-numbers|n", "disable number output on screen", &num);

	args = args[1 .. $];
	Mt19937 gen;
	gen.seed (unpredictableSeed);
	randomShuffle (args);

	foreach (i, arg; args) {
		if (num) writeln (arg);
		else writefln ("%s: %s", i, arg);
	}

}

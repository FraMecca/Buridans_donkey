import std.string;
import std.array : array;
import std.random;
import std.file;

const (string[]) shuffle(string[] args, const string t)
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

void handleRequest(scope HTTPServerRequest req, scope HTTPServerResponse res)
{
    immutable path = req.requestPath.bySegment.array;
    enforce(path.length == 3); // path[0] == ""
    auto engine = path[1].toString;
    auto args = path[2].toString.split(",");
    const result = shuffle(args, engine);
    immutable body = "Asino says:</br><ul>" ~ "<li>" ~ result.join("</li><li>") ~ "</ul>";
    res.headers["Content-Type"] = "text/html";
    res.writeBody(body);
}

shared static this()
{
    auto settings = new HTTPServerSettings;
    settings.port = 8080;
    settings.bindAddresses = ["::1", "127.0.0.1"];

    listenHTTP(settings, &handleRequest);
}

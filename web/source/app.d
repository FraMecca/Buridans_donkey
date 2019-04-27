import std.string;
import std.array : array;
import std.random;
import std.file;

import vibe.http.server;
import taggedalgebraic;

struct Error {};
union U {
    string[] args;
    Error e;
}

alias Result = TaggedUnion!U;

auto shuffle(string[] args, const string t)
{
    Result r;
	switch(t){
    case "mt":
		Mt19937 gen;
		gen.seed(unpredictableSeed);
		args.randomShuffle(gen);
        break;
	case "x":
		Xorshift32 gen;
		gen.seed(unpredictableSeed);
		args.randomShuffle(gen);
        break;
	case "du":
		auto gen = DevRandomGen!"/dev/urandom"();
		args.randomShuffle(gen);
        break;
	case "dr":
		auto gen = DevRandomGen!"/dev/random"();
		args.randomShuffle(gen);
        break;
    default:
        r = Error();
        return r;
	}

    r = args;
	return r ;
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
    void error(){
        res.statusCode = 400;
    }

    immutable path = req.requestPath.bySegment.array;
    if(path.length != 3){// path[0] == ""
        error();
        return ;
    }

    auto engine = path[1].name;
    auto args = path[2].name.split(",");
    const result = shuffle(args, engine);
    result.visit!((string [] r) {
            res.headers["Content-Type"] = "text/html";
            immutable body = "Asino says:</br>" ~
                                 (r.length == 2 ?
                                  r[0] :
                                  "<ul><li>" ~ r.join("</li><li>") ~ "</ul>");
            res.writeBody(body);
        },
        (Error e) { error(); }
    );
}

shared static this()
{
    auto settings = new HTTPServerSettings;
    settings.port = 8080;
    settings.bindAddresses = ["::1", "127.0.0.1"];

    listenHTTP(settings, &handleRequest);
}

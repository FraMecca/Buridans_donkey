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

enum firstPage = `<h1> Buridan's Donkey </h1>
<blockquote>
...a man, being just as hungry as thirsty, and placed in between food and drink, must necessarily remain where he is and starve to death.
</blockquote>
<p> This is the Buridan's Donkey main page.</p>
<p> Do not be afraid to ask for the help of the Donkey</p>
<p> you have four possibilities:<ul>
<li><a href="/x/true,false">/x/true,false</a>: to use Xorshift</li>
<li><a href="/mt/true,false">/mt/true,false</a>: to use Mersenne Twister</li>
<li><a href="/du/true,false">/du/true,false</a>: to use /dev/urandom</li>
<li><a href="/dr/true,false">/dr/true,false</a>: to use /dev/random</li>
</ul></p>
`;

void indexPage(scope HTTPServerRequest req, scope HTTPServerResponse res)
{
    res.writeBody(firstPage);
}

void handleRequest(scope HTTPServerRequest req, scope HTTPServerResponse res)
{
    void error(){
        immutable resp = "Invalid request.<br>For usage see <a href=\"/\">main page</a>";
        res.statusCode = 400;
        res.writeBody(resp);
    }

    res.headers["Content-Type"] = "text/html";

    if(req.path == "/" || req.path == "/index.html")
        return indexPage(req, res);

    immutable path = req.requestPath.bySegment.array;
    if(path.length != 3){// path[0] == ""
        error();
        return ;
    }

    auto engine = path[1].name;
    auto args = path[2].name.split(",");
    const result = shuffle(args, engine);

    result.visit!((string [] r) {
            immutable body = "Asino says:</br>" ~
                                 (r.length == 2 ?
                                  r[0] :
                                  "<ul><li>" ~ r.join("</li><li>") ~ "</ul>");
            res.writeBody(body);
        },
        (Error e) { error(); }
    );
}

void main(string[] argv)
{
    import std.getopt;
    import vibe.core.core : runEventLoop, lowerPrivileges;

    ushort port = 8080;
    string host = "127.0.0.1";
    auto rslt = getopt(argv,
                       "port|p", "Bind to this port.", &port,
                       "host|H", "Listen to this interface.", &host,
    );

    if (rslt.helpWanted){
        defaultGetoptPrinter("Some information about the program.",
                    rslt.options);
        return;
    }
    auto settings = new HTTPServerSettings;
    settings.port = port;
    settings.bindAddresses = [host];

    listenHTTP(settings, &handleRequest);
    lowerPrivileges();
    runEventLoop();
}

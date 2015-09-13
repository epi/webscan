import std.conv : text, to;

import vibe.core.task;
import vibe.core.log;
import vibe.core.concurrency;
import vibe.core.core;
import vibe.core.stream;
import vibe.http.fileserver;
import vibe.http.router;
import vibe.http.server;

enum Orientation
{
	portrait,
	landscape,
}

string toString(Orientation o)
{
	if (o == Orientation.landscape)
		return "landscape";
	else if (o == Orientation.portrait)
		return "portrait";
	assert(0);
}

struct PageSize
{
	string name;
	Orientation orientation;
	int width;
	int height;
	string toString()
	{
		if (!name)
			return "other";
		return text(name, " ", orientation.toString(), " (", width, "mm x ", height, "mm)");
	}
	string toShortString()
	{
		if (!name)
			return "other";
		return text(name, orientation == Orientation.landscape ? "l" : "p");
	}
}

struct Resolution
{
	int dpi;
	string description;
}

void index(HTTPServerRequest req, HTTPServerResponse res)
{
	auto pageSizes = [
		PageSize("A4", Orientation.portrait, 210, 297),
		PageSize("A5", Orientation.portrait, 148, 210),
		PageSize("A5", Orientation.landscape, 210, 148),
		PageSize.init ];
	auto resolutions = [
		Resolution(100, "fastest, low quality"),
		Resolution(150, ""),
		Resolution(200, ""),
		Resolution(300, ""),
		Resolution(600, "slowest, best quality") ];
	res.render!("index.dt", pageSizes, resolutions);
}

void scanWorker(Task caller, int width, int height, int resolution)
{
	import std.process : spawnShell, wait;
	import std.datetime : Clock;
	import std.string : format;

	auto name = text("webscan-", Clock.currTime().toISOString(), ".jpg");
	auto cmd = format(`scanimage --mode Color --compression None --resolution %s -x %s -y %s | convert - "result/%s"`,
		resolution, width, height, name);
	auto pid = spawnShell(cmd);
	pid.wait();
	caller.send(name);
}

void scan(HTTPServerRequest req, HTTPServerResponse res)
{
	Task worker = runWorkerTaskH(&scanWorker,
		Task.getThis,
		req.form["pageWidth"].to!int,
		req.form["pageHeight"].to!int,
		req.form["resolution"].to!int);
	auto fileName = receiveOnly!string();
	res.writeBody(fileName);
}

shared static this()
{
	auto settings = new HTTPServerSettings;
	auto router = new URLRouter;
	router.get("/", &index);
	router.post("/scan", &scan);
	router.get("/result/*", serveStaticFiles("."));
	listenHTTP(settings, router);
	logInfo("Listening on port %s.", settings.port);
}

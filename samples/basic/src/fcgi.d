
module fcgi;

import jaypha.spinna.main.fcgi;
import jaypha.spinna.global;

import jaypha.types;
import jaypha.io.print;

import std.conv;
import std.array;
import std.file;
import std.range;

void errorFn(ulong code, string message, FcgiOutStream err)
{
  if (code/100 == 5) // Only interested in 500 errors.
    err.put(cast(ubyte[])("Spinna Error: "~to!string(code)~": message"));

  response.status(code, message);

  auto buf = appender!string();

  buf.print("error: ",code,",",message);
  response.contentType("text/html; charset=utf-8");
  response.header("Content-Length", to!string(buf.data.length));
  response.entity = cast(ByteArray)buf.data;
}

bool preProcess()
{
  return true;
}

void postProcess()
{
}

shared static this()
{
  fcgiSpinnaRequestProcessor.errorHandler = &errorFn;
  //fcgiSpinnaRequestProcessor.preServiceHandler = &preProcess;
  //fcgiSpinnaRequestProcessor.postServiceHandler = &postProcess;
}

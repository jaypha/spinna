// Written in the D programming language.
/*
 * App module for an FCGI service.
 *
 * Copyright 2015 Jaypha
 *
 * Distributed under the Boost Software License, Version 1.0.
 * (See http://www.boost.org/LICENSE_1_0.txt)
 *
 * Authors: Jason den Dulk
 */

module fcgi;

import jaypha.spinna.main.fcgi;
import jaypha.spinna.global;

import jaypha.types;
import jaypha.io.print;

import std.conv;
import std.array;
import std.file;
import std.range;
import gen.router;

//----------------------------------------------------------------------------
// You need to provide an error handling function in your project.
// TODO. Maybe have this server as a default.

void errorFn(ulong code, string message, ref fcgiRequestProcessor.OutputRange err)
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

//----------------------------------------------------------------------------
// These functions are optional. They are defined here as a sample

bool preProcess()
{
  return true;
}

void postProcess()
{
}

//----------------------------------------------------------------------------

shared static this()
{
  // Mandatory
  fcgiRequestProcessor.errorHandler = &errorFn;
  fcgiRequestProcessor.findRoute = &findRoute;

  // Optional
  fcgiRequestProcessor.preServiceHandler = &preProcess;
  fcgiRequestProcessor.postServiceHandler = &postProcess;
}

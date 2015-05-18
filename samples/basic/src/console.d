// Written in the D programming language.
/*
 * App module for a console service.
 *
 * Copyright 2015 Jaypha
 *
 * Distributed under the Boost Software License, Version 1.0.
 * (See http://www.boost.org/LICENSE_1_0.txt)
 *
 * Authors: Jason den Dulk
 */

module console;

import jaypha.spinna.main.console;
import jaypha.spinna.global;

import std.conv;
import std.array;
import std.file;
import std.range;

import gen.router;

void errorFn(ulong code, string message, ref consoleRequestProcessor.OutputRange err)
{
  if (code/100 == 5) // Only interested in 5xx type errors.
  {
    err.put(cast(immutable(ubyte)[])("Spinna Error: "~to!string(code)~": message\n"));
    err.put(cast(immutable(ubyte)[])(message~"\n"));
  }

  response.status(code, message);

  auto buf = appender!string();

  buf.put("error: "~to!string(code)~", "~message);
  response.contentType("text/plain; charset=utf-8");
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

static this()
{
  consoleRequestProcessor.errorHandler = &errorFn;
  consoleRequestProcessor.findRoute = &findRoute;
}

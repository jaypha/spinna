// Written in the D programming language.
/*
 * App module for a Vibed based site.
 *
 * Copyright 2015 Jaypha
 *
 * Distributed under the Boost Software License, Version 1.0.
 * (See http://www.boost.org/LICENSE_1_0.txt)
 *
 * Authors: Jason den Dulk
 */

module app;

import vibe.stream.wrapper;
import vibe.core.log;

import jaypha.spinna.main.vibe;
import jaypha.spinna.global;

import jaypha.types;
import jaypha.io.print;

import std.conv;
import std.array;
import std.file;
import std.range;

import gen.router;

void errorFn(ulong code, string message, ref vibedRequestProcessor.OutputRange err)
{
  if (code/100 == 5) // Only interested in 5xx type errors.
    logInfo("Spinna Error: "~to!string(code)~": "~message);

  response.status(code, "Internal Error");

  auto buf = appender!string();

  buf.print("error: ",code,",",message);
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

shared static this()
{
  vibedRequestProcessor.errorHandler = &errorFn;
  vibedRequestProcessor.findRoute = &findRoute;
  startVibeD(8080);
}

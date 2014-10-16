/*
 * Support function for JSON based requests/resposnes.
 *
 * Copyright 2014 Jaypha
 *
 * Distributed under the Boost Software License, Version 1.0.
 * (See http://www.boost.org/LICENSE_1_0.txt)
 *
 * Authors: Jason den Dulk
 *
 * Written in the D programming language.
 */

module jaypha.spinna.json;

import jaypha.types;

import jaypha.spinna.response;

import std.json;
import std.conv;

//--------------------------------------------------------------------------
// Transfers the contents of a JSON structure into an HTTP response.

void transfer(ref JSONValue doc, ref HttpResponse response, bool noCache = true)
{
  auto s = toJSON(&doc);

  if (noCache)
    response.noCache();
  response.content_type("application/json; charset=utf-8");
  response.header("Content-Length", to!string(s.length));
  response.entity = cast(ByteArray)s;
}

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

JSONValue fromStrStr(strstr value)
{
  JSONValue[string] a;
  foreach (i,v; value)
    a[i] = JSONValue(v);
  return JSONValue(a);
}

//--------------------------------------------------------------------------
// Transfers the contents of a JSON structure into an HTTP response.

void copy(ref JSONValue doc, ref HttpResponse response, bool noCache = true)
{
  auto s = toJSON(&doc);

  if (noCache)
    response.noCache();
  response.contentType("application/json; charset=utf-8");
  response.header("Content-Length", to!string(s.length));
  response.entity = cast(ByteArray)s;
}

// Deprecated
void transfer(ref JSONValue doc, ref HttpResponse response, bool noCache = true)
{
  copy(doc,response,noCache);
}

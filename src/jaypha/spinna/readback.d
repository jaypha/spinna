//Written in the D programming language
/*
 * Generates info about current state.
 *
 * Copyright (C) 2014 Jaypha.
 *
 * Distributed under the Boost Software License, Version 1.0.
 * (See http://www.boost.org/LICENSE_1_0.txt)
 *
 * Authors: Jason den Dulk
 */

module jaypha.spinna.readback;

import jaypha.types;

import jaypha.spinna.global;

import std.array;

//---------------------------------------------------------------------------
// readbackInfo creates a string containing information about the request.
// This is useful for debugging.

string readbackInfo()
{
  auto s = appender!string();

  s.put("** Environment **\n");
  foreach (a,b; request.environment)
    s.put(a~": "~b~"\n");

  s.put("** Gets **\n");

  foreach (i,v;request.gets.all)
  {
    s.put(i~": ");
    foreach(j;v)
    {
      s.put(j~",");
    }
    s.put("\n");
  }

  s.put("** Posts **\n");

  foreach (i,v;request.posts.all)
  {
    s.put(i~": ");
    foreach(j;v)
    {
      s.put(j~",");
    }
    s.put("\n");
  }

  s.put("** Cookies **\n");

  foreach (i,c; request.cookies)
    s.put(i~": "~c.value~"\n");
    
  s.put("** Session **\n");

  s.put("session id = "~session.sessionId~"\n");
  session.load();

  foreach (i,ac; session)
  {
    s.put(i~": ");
    foreach (j,cs;ac)
      s.put(j~"="~cs~", ");
    s.put("\n");
  }

  s.put("** Content **\n");
  s.put(cast(string)request.rawInput);

  return s.data;
}

//---------------------------------------------------------------------------
// A request processing function to return readback info.

void getReadback()
{
  response.entity = cast(ByteArray)readbackInfo();
}

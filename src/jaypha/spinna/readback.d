/*
 * Report current state
 *
 * Copyright (C) 2014 Jaypha.
 *
 * Distributed under the Boost Software License, Version 1.0.
 * (See http://www.boost.org/LICENSE_1_0.txt)
 *
 * Authors: Jason den Dulk
 *
 * Written in the D programming language.
 */

module jaypha.spinna.readback;

import jaypha.types;

import jaypha.spinna.global;
import jaypha.spinna.pagebuilder.document;

import std.array;

void get_readback()
{
  version(console)
  {
    response.entity = cast(ByteArray)readback_info();
  }
  else
  {
    auto doc = new Document("readback");

    doc.page_body.add(readback_info());
    transfer(doc, response, false);
  }
}

string readback_info()
{
  auto s = appender!string();

  version(console)
  {
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

    s.put("session id = "~session.session_id~"\n");
    session.load();

    foreach (i,ac; session)
    {
      s.put("i: ");
      foreach (j,cs;ac)
        s.put(j~"="~cs~", ");
      s.put("\n");
    }

    s.put("** Content **\n");
    s.put(cast(string)request.raw_input);
  }
  else
  {
    s.put("<h1>ReadBack</h1>");
    s.put("<h4>Environment</h4>");
    s.put("<table>");

    foreach (a,b; request.environment)
      s.put("<tr><td>"~a~"</td><td style='padding-left:5px'>"~b~"</td></tr>");

    s.put("</table>");

    s.put("<h4>Gets</h4>");
    s.put("<table>");

    foreach (i,v;request.gets.all)
    {
      s.put("<tr><td>"~i~"</td><td style='padding-left:5px'>");
      foreach(j;v)
      {
        s.put(j~",");
      }
      s.put("</td></tr>");
    }

    s.put("<h4>Puts</h4>");
    s.put("<table>");

    foreach (i,v;request.posts.all)
    {
      s.put("<tr><td>"~i~"</td><td style='padding-left:5px'>");
      foreach(j;v)
      {
        s.put(j~",");
      }
      s.put("</td></tr>");
    }

    s.put("<h4>Cookies</h4>");

    foreach (i,c; request.cookies)
      s.put("<p>"~i~": "~c.value~"</p>");
      
    s.put("<h4>Session</h4>");

    s.put("<p>session id = "~session.session_id~"</p>");
    session.load();

    foreach (i,ac; session)
    {
      s.put(i~": ");
      foreach (j,cs;ac)
        s.put(j~"="~cs~", ");
      s.put("<br/>");
    }

    s.put("<pre>\n");
    s.put(cast(string)request.raw_input);
    s.put("</pre>");
  }

  return s.data;
}

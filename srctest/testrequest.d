//Written in the D programming language
/*
 * Test module for HttpRequest
 *
 * Copyright 2013 Jaypha
 *
 * Distributed under the Boost Software License, Version 1.0.
 * (See http://www.boost.org/LICENSE_1_0.txt)
 *
 * Authors: Jason den Dulk
 */

module testrequest;

import jaypha.spinna.request;
import jaypha.inet.mime.reading;

import std.stdio;
import std.range;
import std.conv;
import std.string;

import jaypha.io.dirtyio;

void main(string[] args)
{
  writeln("begin");
  string[string] env;
  HttpRequest request;

  if (args.length > 1)
  {
    env["REQUEST_METHOD"] = args[1];
    env["QUERY_STRING"] = args[2];
    
    auto win = ReadIn(stdin);
    auto entity = mimeEntityReader(win);

    foreach (h; entity.headers)
    {
      switch (h.name)
      {
        case "Content-Type":
          env["CONTENT_TYPE"] = strip(h.fieldBody);
          break;
        case "Cookie":
          env["HTTP_COOKIE"] = strip(h.fieldBody);
          break;
        case "Referer":
          env["HTTP_REFERER"] = strip(h.fieldBody);
          break;
        case "Content-Length":
          env["CONTENT_LENGTH"] = strip(h.fieldBody);
          break;
        default:
          ;
      }
    }

    request.prepare(env,entity.content);
  }
  else
  {
    string txt = "r=5&q=10&t=3+12&n=8";

    env["QUERY_STRING"] = "a=5&b=10;j=3+12&a=8";
    env["REQUEST_METHOD"] = "POST";
    env["CONTENT_LENGTH"] = to!string(txt.length);
    env["CONTENT_TYPE"] = "application/x-www-form-urlencoded";
    ubyte[] bytes = cast(ubyte[])txt.dup;
    auto r1 = inputRangeObject(bytes);
    request.prepare(env,r1);
  }

  auto wout = WriteOut(stdout);
  writeln(request.method());

  writeln("--gets--");
  foreach (i,v;request.gets.all)
  {
    wout.put(i~": ");
    foreach(j;v)
    {
      wout.put(j~",");
    }
    wout.put("\n");
  }

  writeln("--posts--");
  foreach (i,v;request.posts.all)
  {
    wout.put(i~": ");
    foreach(j;v)
    {
      wout.put(j~",");
    }
    wout.put("\n");
  }

  writeln("finish");
}

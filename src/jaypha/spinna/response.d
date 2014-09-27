/*
 * Server side HTTP response.
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

module jaypha.spinna.response;

import std.array;
import std.range;
import std.conv;
import std.algorithm;
import std.datetime;
import std.string;

import jaypha.types;

/*
 * HttpResponse acts as an input range for ByteArrays to allow direct copying
 * to output ranges.
 */

struct HttpResponse
{
  //---------------------------------------------------------------------------
  // entity is the main content.
  //---------------------------------------------------------------------------

  ByteArray entity;

  //---------------------------------------------------------------------------
  // HttpResponse as an input range
  //---------------------------------------------------------------------------
  // This allows for easy outputting via std.range.copy

  uint step = 0;

  @property bool empty() { return step >=3; }

  //------------------------------------

  ByteArray front()
  {
    if (step == 0)
    {
      if (!response_start)
        response_start = get_response_start();

      return cast(ByteArray) response_start;
    }
    else if (step == 1)
    {
      return cast(ByteArray) (headers.data ~ "\r\n");
    }
    else if (step == 2)
      return entity;
    else
      return null;
  }

  //------------------------------------

  void popFront()
  {
    ++step;
  }

  //------------------------------------

  string response_start = null;

  string get_response_start()
  {
    auto b = appender!string();
    b.put("Content-Type: ");
    b.put(mime_type);
    b.put("\r\n");
    b.put("Status: ");
    b.put(to!string(http_status));
    if (http_status_msg !is null)
    {
      b.put(" ");
      b.put(http_status_msg);
    }
    b.put("\r\n");
    return b.data;
  }

  //---------------------------------------------------------------------------
  // Functions for response headers.
  //---------------------------------------------------------------------------

  void status(ulong http_status, string msg = null)
  {
    this.http_status = http_status;
    this.http_status_msg = msg.dup;
  }

  //------------------------------------

  void set_session_cookie(string name, string value, string path = "/", string domain = null)
  {
    headers.put("Set-Cookie: ");
    headers.put(name);
    headers.put("=");
    headers.put(value);
    headers.put(";");
    if (path !is null) { headers.put(" path="); headers.put(path); headers.put(";"); }
    if (domain !is null) { headers.put(" domain="); headers.put(domain); headers.put(";"); }
    headers.put("\r\n");
  }

  //------------------------------------

  void header(string name, const string value)
  {
    headers.put(name);
    headers.put(": ");
    headers.put(value);
    headers.put("\r\n");
  }

  //------------------------------------

  void content_type(string type)
  {
    mime_type = type;
  }

  //---------------------------------------------------------------------------
  // Ensures that the page will not be cached

  void no_cache()
  {
    // Date in the past
    header("Expires", "Mon, 26 Jul 1997 05:00:00 GMT");

    // always modified
    auto d = Clock.currTime(UTC());
    header("Last-Modified",format("%d, %d %s %d %02d:%02d:%02d GMT", d.dayOfWeek,d.day, d.month, d.year, d.hour, d.minute,d.second));

    // HTTP/1.1
    header("Cache-Control", "no-store, no-cache, must-revalidate");
    header("Cache-Control", "post-check=0, pre-check=0");

    // HTTP/1.0
    //header("Pragma", "no-cache");
  }

  //---------------------------------------------------------------------------

  void redirect(string url, int http_status = 303)
  {
    status(http_status);
    header("Location",url);
  }

  void prepare()
  {
    mime_type = "text/plain";
    http_status = 200;
    http_status_msg = "OK";
    headers = appender!string();
  }

  private:
    string mime_type;
    ulong http_status = 200;
    string http_status_msg = "OK";
    private Appender!string headers;
}

unittest
{
  import std.range;
  import std.stdio;

  auto napp = appender!ByteArray;
  HttpResponse response;

  response.entity = cast(ByteArray)("Hello Goodbye\n");

  response.content_type("text/plain");
  response.status(202, "yahoo");
  response.header("X-Content", "just");
  response.copy(napp);

  assert(cast(string)napp.data == "Content-Type: text/plain\r\nStatus: 202 yahoo\r\nX-Content: just\r\n\r\nHello Goodbye\n");
}
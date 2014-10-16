//Written in the D programming language
/*
 * Server side HTTP response.
 *
 * Copyright (C) 2014 Jaypha
 *
 * Distributed under the Boost Software License, Version 1.0.
 * (See http://www.boost.org/LICENSE_1_0.txt)
 *
 * Authors: Jason den Dulk
 */

module jaypha.spinna.response;

import std.array;
import std.range;
import std.conv;
import std.algorithm;
import std.datetime;
import std.string;

import jaypha.types;

import jaypha.inet.mime.header;

struct HttpResponse
{
  //---------------------------------------------------------------------------
  // entity is the main content.
  //---------------------------------------------------------------------------

  ByteArray entity;

  void copy(R)(R range) if (isOutputRange!(R,ByteArray))
  {
    // Headers
    range.put(cast(ByteArray)"Content-Type: ");
    range.put(cast(ByteArray)mimeType);
    range.put(cast(ByteArray)MimeEoln);

    range.put(cast(ByteArray)"Status: ");
    range.put(cast(ByteArray)to!string(httpStatus));
    if (httpStatusMsg !is null)
    {
      range.put(cast(ByteArray)" ");
      range.put(cast(ByteArray)httpStatusMsg);
    }
    range.put(cast(ByteArray)MimeEoln);

    range.put(cast(ByteArray)headers.data);
    range.put(cast(ByteArray)MimeEoln);

    // Body
  
    range.put(entity);
  }

  //---------------------------------------------------------------------------
  // Functions for response headers.
  //---------------------------------------------------------------------------

  void status(ulong status, string msg = null)
  {
    httpStatus = status;
    httpStatusMsg = msg;
  }

  //------------------------------------

  void setSessionCookie(string name, string value, string path = "/", string domain = null)
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

  //-------------------------------------------------------

  void header(string name, const string value)
  {
    headers.put(name);
    headers.put(": ");
    headers.put(value);
    headers.put("\r\n");
  }

  //-------------------------------------------------------

  @property void contentType(string type)
  {
    mimeType = type;
  }

  //-------------------------------------------------------
  // Ensures that the page will not be cached

  void noCache()
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

  //-------------------------------------------------------

  void redirect(string url, int httpStatus = 303)
  {
    status(httpStatus);
    header("Location",url);
  }

  //-------------------------------------------------------
  // Resets to initial state

  void clear()
  {
    mimeType = "text/plain";
    httpStatus = 200;
    httpStatusMsg = "OK";
    headers = appender!string();
    entity = entity.init;
  }

  private:
    string mimeType = "text/plain";
    ulong httpStatus = 200;
    string httpStatusMsg = "OK";
    private Appender!string headers;
}

unittest
{
  import std.range;
  import std.stdio;

  auto napp = appender!ByteArray;
  HttpResponse response;

  response.entity = cast(ByteArray)("Hello Goodbye\n");

  response.contentType = "text/plain";
  response.status(202, "yahoo");
  response.header("X-Content", "just");
  response.copy(napp);

  assert(cast(string)napp.data == "Content-Type: text/plain\r\nStatus: 202 yahoo\r\nX-Content: just\r\n\r\nHello Goodbye\n");
}
/*
 * An interface to the FastCGI library provided by Open Market.
 *
 * Provides a function to loop through requests, creating a thread for each
 * request.
 *
 * Also provides adapters to allow access to the input and output streams and
 * the environment variables via D style interfaces.
 *
 * Copyright 2013 Jaypha
 *
 * Distributed under the Boost Software License, Version 1.0.
 * (See http://www.boost.org/LICENSE_1_0.txt)
 *
 * Authors: Jason den Dulk
 *
 * Written in the D programming language.
 */

module jaypha.fcgi.loop;

import std.concurrency;
import std.array;
import std.exception;

import jaypha.fcgi.c.fcgiapp;


// Note: HTTP input and output are octet streams. That is, an array of ubytes.

//---------------------------------------------------------------------------

/**
 * FCGI_Outstream
 *
 * An adapter for outgoing FCGI streams that acts as an output range of ubytes.
 */

struct FCGI_OutStream
{
  FCGX_Stream* stream;

  this(FCGX_Stream* _stream)
  {
    stream = _stream;
  }

  void put(const(ubyte)[] s)
  {
    FCGX_PutStr(cast(const(char)*)s.ptr, cast(int)s.length, stream);
  }

  void put(const ubyte c)
  {
    FCGX_PutChar(cast(const(char))c, stream);
  }
}

//---------------------------------------------------------------------------

/**
 * FCGI_InStream
 *
 * An adapter for incoming FCGI streams that acts as an input range of ubytes.
 */

struct FCGI_InStream
{
  FCGX_Stream* stream;
  int current = -1;

  this(FCGX_Stream* _stream)
  {
    stream = _stream;
    popFront();
  }

  bool empty = false;

  ubyte front;

  void popFront()
  {
    auto next =  FCGX_GetChar(stream);
    if (next == -1) empty = true;
    else
      front = cast(ubyte) next;
  }

  /+
  immutable(ubyte)[] grab_it_all()
  {
    auto a = appender!(ubyte[]);
    int c;

    while ((c = FCGX_GetChar(stream)) != -1)
    {
      a.put(cast(ubyte)c);
    }
    return assumeUnique(a.data);
  }
  +/
}

//---------------------------------------------------------------------------

/**
 * FCGI_Request
 *
 * Bundle up stuff used by a request.
 */

struct FCGI_Request
{
  private FCGX_Request request;

  FCGI_OutStream fcgi_out;
  FCGI_OutStream fcgi_err;
  FCGI_InStream  fcgi_in;

  string[string] env;

  this(FCGX_Request r)
  {
    request = r;
    fcgi_out = FCGI_OutStream(request._out);
    fcgi_err = FCGI_OutStream(request._err);
    fcgi_in  = FCGI_InStream(request._in);
    env = pp_to_assoc(cast(const(char)**) r.envp);
  }
  
}

//---------------------------------------------------------------------------

private class __Request
{
  FCGX_Request request;
}

void FCGI_loop(void function(ref FCGI_Request) fp)
{
  FCGX_Init();

  while(true)
  {
    auto r = new __Request(); // Guarantees that request is different each time.

    FCGX_InitRequest(&r.request, 0, 0);
    FCGX_Accept_r(&r.request);

    //auto s = new FCGI_Request(r.request);
    //fp(s);
    //FCGX_Finish_r(&r.request);
    spawn(&new_thread, cast(shared(__Request))r,fp);
  }
}

//---------------------------------------------------------------------------

private void new_thread(shared(__Request) r, void function(ref FCGI_Request) fp)
{
  auto rr = cast(__Request) r;
  scope(exit) { FCGX_FFlush(rr.request._out); FCGX_Finish_r(&rr.request); }
  auto s = FCGI_Request(rr.request);
  fp(s);
}

//---------------------------------------------------------------------------

/*
 * Takes the environment variables as given by the FCGI and puts them
 * into an associative array.
 *
 * In FCGI, the environment variables are given in a two dimensional
 * char array.
 * The outer array is null terminated.
 * The inner arrays are C strings of the format "<name>=<value>".
 */


string[string] pp_to_assoc(const(char)** pp)
{
  string[string] ass;

  for (const(char)** p = pp; *p !is null; ++p)
  {
    const(char)* c = *p;
    auto napp = appender!string();
    while (*c != '=')
    {
      napp.put(*c);
      ++c;
    }
    ++c;
    auto vapp = appender!string();
    while (*c != '\0')
    {
      vapp.put(*c);
      ++c;
    }
    ass[napp.data] = vapp.data;
  }
  return ass;
}

//---------------------------------------------------------------------------

unittest
{
  import std.range, std.string;

  static assert(isOutputRange!(FCGI_OutStream,const(ubyte)[]));
  static assert(isOutputRange!(FCGI_OutStream,const ubyte));

  const(char)*[] pp;
  pp ~= std.string.toStringz("timber=alice");
  pp ~= std.string.toStringz("usb=false");
  pp ~= null;

  auto ass = pp_to_assoc(pp.ptr);

  assert (ass.length == 2);
  assert ("timber" in ass);
  assert (ass["timber"] == "alice");
  assert ("usb" in ass);
  assert (ass["usb"] == "false");
}


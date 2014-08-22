/*
 * HTTP Cookies
 *
 * Copyright 2013 Jaypha.
 *
 * Distributed under the Boost Software License, Version 1.0.
 * (See http://www.boost.org/LICENSE_1_0.txt)
 *
 * Authors: Jason den Dulk
 *
 * Written in the D language.
 */

module jaypha.http.cookie;

import jaypha.string;

import std.array;
import std.string;

/*
 * RFC6265 - Cookies
 */

struct HttpCookie
{
  string value;
  string path;
  string domain;
  string port;

  this(string v) { value = v; }
}

/*
 * According to RFC6265, cookies are of the form
 *   name=value[;name=value]*
 *
 * values are octets (i.e. ubytes).
 */

HttpCookie[string] extract_cookies(const(char)[] cookiestr)
{
  HttpCookie[string] cookies;

  void extract(const(char)[] pair)
  {
    auto r = split(pair,"=");
    
    //int r = indexOf(pair.ptr,'=',pair.length);
    cookies[r[0].idup] = HttpCookie(r[1].idup);
  }

  auto t = split(cookiestr, ";");
  foreach (tt;t)
    extract(tt);
  return cookies;
}

// TODO better unittests.
unittest
{
  auto c = extract_cookies("SPINNA_SESSION=7DE75CF0AD563D3E66561704ED8B7ADA");
  
}
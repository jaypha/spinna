//Written in the D programming language
/*
 * HTTP Cookies
 *
 * Copyright (C) 2013 Jaypha.
 *
 * Distributed under the Boost Software License, Version 1.0.
 * (See http://www.boost.org/LICENSE_1_0.txt)
 *
 * Authors: Jason den Dulk
 */

/*
 * RFCs: 6265
 */

module jaypha.inet.http.cookie;

import jaypha.string;

import std.array;
import std.string;

/*
 * RFC6265 - Cookies
 */

struct HttpCookie
{
  string name;
  string value;

  // The following are not used in requests.
  string path;
  string domain;
  string port;
}

/*
 * According to RFC6265, cookies are of the form
 *   name=value[;name=value]*
 *
 * values are octets (i.e. ubytes).
 */

HttpCookie[string] extractCookies(string s)
{
  HttpCookie[string] cookies;

  void extract(string pair)
  {
    auto r = split(pair,"=");
    if (r.length == 1) return; // Ignore if no '=' present
    auto name = strip(r[0]);
    if (name.empty) return; // Ignore if name is empty.
    //int r = indexOf(pair.ptr,'=',pair.length);
    cookies[name] = HttpCookie(name, strip(r[1]));
  }

  auto pairs = split(s, ";");
  foreach (pair;pairs)
    extract(pair);
  return cookies;
}

unittest
{
  string t1 = " abcd = 123 ; as ; xyz=;=dhg ;john=tool";
  auto c = extractCookies(t1);
  assert(c.length == 3);
  assert("abcd" in c);
  assert(c["abcd"].name == "abcd");
  assert(c["abcd"].value == "123");
  assert("xyz" in c);
  assert(c["xyz"].name == "xyz");
  assert(c["xyz"].value.empty);
  assert("john" in c);
  assert(c["john"].name == "john");
  assert(c["john"].value == "tool");
}

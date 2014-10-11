//Written in the D programming language
/*
 * Functions for working with URLs.
 *
 * Copyright 2013 Jaypha
 *
 * Distributed under the Boost Software License, Version 1.0.
 * (See http://www.boost.org/LICENSE_1_0.txt)
 *
 * Authors: Jason den Dulk
 */

module jaypha.url;

import std.uri;
import std.algorithm;
import std.string;

import jaypha.types;

import jaypha.algorithm;

string create_query_parm(string name, string value)
{
  return encodeComponent(name) ~ "=" ~ encodeComponent(value);
}

string url_add_query_parm(string url, string name, string value)
{
  char u = (canFind(url, '?')?'&':'?');

  return url ~ u ~ create_query_parm(name, value);;
}

string url_add_query_params(string url, strstr parms)
{
  string u = url ~ (canFind(url, '?')?"&":"?");
  u ~= parms.meld!create_query_parm.join("&");
  return u;
}

unittest
{
  //import std.stdio;

  string x = "abc.com";
  x = url_add_query_parm(x, "a", "b");
  x = url_add_query_parm(x, "df", "y=&4");
  assert(x == "abc.com?a=b&df="~encodeComponent("y=&4"));
}

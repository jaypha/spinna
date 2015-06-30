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

string createQueryParm(string name, string value)
{
  return encodeComponent(name) ~ "=" ~ encodeComponent(value);
}

string addQueryParm(string url, string name, string value)
{
  char u = (canFind(url, '?')?'&':'?');
  return url ~ u ~ createQueryParm(name, value);;
}

string addQueryParms(string url, strstr parms)
{
  char u = (canFind(url, '?')?'&':'?');
  return url ~ u ~ parms.meld!createQueryParm.join("&");
}

unittest
{
  //import std.stdio;

  string x = "abc.com";
  x = addQueryParm(x, "a", "b");
  x = addQueryParm(x, "df", "y=&4");
  assert(x == "abc.com?a=b&df="~encodeComponent("y=&4"));

  strstr stuff = [ "m" : "12", "n" : "@ word", "q#" : "io" ];
  x = addQueryParms("xyz.com", stuff);
  import std.stdio;
  writeln(x);
}

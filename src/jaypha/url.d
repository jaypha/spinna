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
  string u = url ~ (canFind(url, '?')?"&":"?");

  u ~= create_query_parm(name, value);

  return u;
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

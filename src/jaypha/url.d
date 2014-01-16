module jaypha.url;

import std.uri;
import std.algorithm;

string url_add_query_parm(string url, string name, string value)
{
  string u = url ~ (canFind(url, '?')?"&":"?");

  u ~= encodeComponent(name) ~ "=" ~ encodeComponent(value);

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
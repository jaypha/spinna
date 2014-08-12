/*
 * Building blocks for the router.
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

module jaypha.spinna.router_tools;

public import jaypha.types;

struct ActionInfo
{
  string action;
  void delegate() service;
}

template param_copy(R...) {
  static if (R.length)
  {
    const char[] param_copy = "p[\""~R[0]~"\"] = m.front[\""~R[0]~"\"];" ~ param_copy!(R[1..R.length]);
  }
  else
    const char[] param_copy = "";
}

template match_regex_route(string action, string rx, string fn, cp ...)
{
  const char[] match_regex_route = 
    "{auto m = match(path, "~rx~");"
    "if (m) { strstr p; "~param_copy!(cp)~" return "
    "ActionInfo(\""~action~"\",wrap_service(p, &"~fn~"));}}";
}

template match_static_route
  (string action, string pattern, string fn)
{
  const char[] match_static_route = 
    "if (path == \""~pattern~"\") return "
    "ActionInfo(\""~action~"\",toDelegate(&"~fn~"));";
}

template match_sub_route(string pattern, string fn)
{
  const char[] match_sub_route =
  "{ auto s = path.chompPrefix(\""~pattern~"\"); "
  " if (s.length != path.length) return "~fn~"(s); }";
}

auto wrap_service(strstr p, void function(strstr) fn)
{
  void f() { fn(p); }
  return &f;
}

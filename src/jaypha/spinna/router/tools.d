// Written in the D programming language.
/*
 * Building blocks for the router.
 *
 * Copyright 2014 Jaypha
 *
 * Distributed under the Boost Software License, Version 1.0.
 * (See http://www.boost.org/LICENSE_1_0.txt)
 *
 * Authors: Jason den Dulk
 */

module jaypha.spinna.router.tools;

public import jaypha.types;

public import jaypha.spinna.router.actioninfo;

template paramCopy(R...) {
  static if (R.length)
  {
    const char[] paramCopy = "p[\""~R[0]~"\"] = m.front[\""~R[0]~"\"];" ~ paramCopy!(R[1..R.length]);
  }
  else
    const char[] paramCopy = "";
}

/+
enum string match_regex_route
(
  string rx,
  string method,
  string action,
  string fn,
  cp ...
) =
    "if (method == \""~method~"\") {auto m = match(path, "~rx~");"
    "if (m) { strstr p; "~param_copy!(cp)~" return "
    "ActionInfo(\""~action~"\",wrap_service(p, &"~fn~"));}}";
+/

template matchRegexRoute(string rx, string method, string action, string fn, cp ...)
{
  enum matchRegexRoute = 
    (method?"if (method == \""~method~"\") ":"")~"{auto m = match(path, "~rx~");"
    "if (m) { strstr p; "~paramCopy!(cp)~" return "
    "ActionInfo(\""~action~"\",wrapService(p, &"~fn~"));}}";
}


enum string matchStaticRoute
(
  string pattern,
  string method,
  string action,
  string fn
) =
    "if ("~(method?"method==\""~method~"\" && ":"")~"path == \""~pattern~"\") return "
    "ActionInfo(\""~action~"\",toDelegate(&"~fn~"));";

auto wrapService(strstr p, void function(strstr) fn)
{
  void f() { fn(p); }
  return &f;
}

enum matchFilePattern(string root, string rx, string method, string action)
=
"{auto m = match(path, "~rx~");"
"if (m && method == \"get\") { auto fileName = \""~root~"\"~path;"
"if (exists(fileName) && isFile(fileName)) return ActionInfo(\""~action~"\", () { jaypha.spinna.fileStreamer.streamFile(fileName); });"
"}}";

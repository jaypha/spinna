//Written in the D programming language
/*
 * Test module for router tools  (Deprecated).
 *
 * Copyright: Copyright (C) 2013 Jaypha
 *
 * Distributed under the Boost Software License, Version 1.0.
 * (See http://www.boost.org/LICENSE_1_0.txt)
 *
 * Authors: Jason den Dulk
 */

module testrouter;

import jaypha.spinna.router.tools;

import std.stdio;
import std.array;
import std.string;

void main()
{
  writeln(matchStaticRoute!("/home", null, "admin.home", "x.y"));
  writeln(matchRegexRoute!("[a..b]", "get", "/homerx", "", "a.b", "x.z"));

  writeln(matchStaticRoute!("/home", "post", "admin.home", "x.y"));
  writeln(matchRegexRoute!("[a..b]", null, "/homerx", "", "a.b", "x.z"));
}

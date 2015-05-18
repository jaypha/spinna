//Written in the D programming language
/*
 * Test module for Embed
 *
 * Copyright: Copyright (C) 2013 Jaypha
 *
 * Distributed under the Boost Software License, Version 1.0.
 * (See http://www.boost.org/LICENSE_1_0.txt)
 *
 * Authors: Jason den Dulk
 */


module testembed;

import jaypha.spinna.embed;

import std.stdio;

void main()
{
  //string ss = tpl_to_d!("abcd \"<%=a%>\" cdf","write")();

  //writeln(ss);
  auto count = 12;
  auto x = true;
  auto title = "Heaven";

  mixin(embedD(import("testembed.tpl")));
}

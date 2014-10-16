//Written in the D programming language
/*
 * Extract properties from a string.
 *
 * Copyright (C) 2014 Jaypha
 *
 * Distributed under the Boost Software License, Version 1.0.
 * (See http://www.boost.org/LICENSE_1_0.txt)
 *
 * Authors: Jason den Dulk
 */

module jaypha.properties;

//import std.algorithm;
//import std.array;

/*
 * Properties are one per line in the format "property : value".
 * '#' indicates comment.
 */

string[string] extractProperties(string source)
{
  import std.string : splitLines, indexOf, strip;

  string[string] props;
  foreach (l; splitLines(source))
  {
    auto v = indexOf(l,'#');
    if (v != -1)
      l = l[0..v];
    auto ind = indexOf(l,':');
    if (ind >0)
    {
      auto name = strip(l[0..ind]);
      if (name.length)
        props[name] = strip(l[ind+1..$]);
    }
  }
  return props;
}

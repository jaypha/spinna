/*
 * Quick and dirty output range wrapper for File.
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

module jaypha.io.writeout;

import std.stdio;

struct WriteOut
{
  File file;

  void put(immutable(ubyte)[] s) { file.rawWrite(s); }
  void put(string s) { file.write(s); }
  void put(dchar c) { file.write(c); }
}

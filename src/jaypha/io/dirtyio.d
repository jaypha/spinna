//Written in the D programming language
/*
 * Quick and dirty range wrappers for File.
 *
 * Copyright 2014 Jaypha
 *
 * Distributed under the Boost Software License, Version 1.0.
 * (See http://www.boost.org/LICENSE_1_0.txt)
 *
 * Authors: Jason den Dulk
 */

module jaypha.io.dirtyio;

import std.stdio;

struct WriteOut
{
  File file;

  void put(immutable(ubyte)[] s) { file.rawWrite(s); }
  void put(string s) { file.write(s); }
  void put(dchar c) { file.write(c); }
}

struct ReadIn
{
  File file;

  private ubyte[1] buffer;
  bool empty = false;

  @property ubyte front() { return buffer[0]; }
  void popFront()
  {
    auto r = file.rawRead(buffer);
    empty = (r.length == 0);
  }

  this(File f) { file = f; popFront(); }
}

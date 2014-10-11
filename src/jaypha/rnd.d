/*
 * Wrapper for std.random.rndGen and some useful routines.
 *
 * Copyright 2013 Jaypha
 *
 * Distributed under the Boost Software License, Version 1.0.
 * (See http://www.boost.org/LICENSE_1_0.txt)
 *
 * Authors: Jason den Dulk
 *
 * Written in the D programming language.
 */

module jaypha.rnd;

import std.random;
import std.algorithm;
import std.array;
import std.range;
import std.conv;

import jaypha.conv;

//-----------------------------------------------------------------------------
// A wrapper for rndGen to prevent copying, provided by monarch_dodra.

struct Rnd
{
  enum empty = false;
  void popFront()
  {
    rndGen.popFront();
  }
  @property auto front()
  {
    return rndGen.front;
  }
}

Rnd rnd() { return Rnd(); }

//-----------------------------------------------------------------------------
// A randomly generated string of hex characters. Useful for filenames.

string rnd_hex(uint bytes)
{
  return rnd().take(bytes).map!(bin2hex)().join();
}

//-----------------------------------------------------------------------------
// A random string of ASCII printable characters. Useful for passwords.

string rndString(uint size)
{
  auto bytes = appender!string();
  bytes.reserve(size);
//  ubyte[] bytes;
  //bytes.length = size;
  foreach (j; 0..size)
    bytes.put(cast(char) uniform(33, 126));
  return bytes.data;
}

alias rndString rnd_string;

//-----------------------------------------------------------------------------

string rndId(uint size)
{
  auto bytes = appender!string();
  bytes.reserve(size);
//  ubyte[] bytes;
  //bytes.length = size;
  foreach (j; 0..size)
    bytes.put(cast(char) uniform(97, 123));
  return bytes.data;
}

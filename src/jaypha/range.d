//Written in the D programming language
/*
 * Suuport functions to use with ranges.
 *
 * Copyright (C) 2013 Jaypha
 *
 * Distributed under the Boost Software License, Version 1.0.
 * (See http://www.boost.org/LICENSE_1_0.txt)
 *
 * Authors: Jason den Dulk
 */

module jaypha.range;

import std.algorithm;
public import std.range;
import std.traits;
import std.exception;

//----------------------------------------------------------------------------
// Consumes the front of the range as long the elements are inside pattern.

void munch(R,E)(ref R r, E pattern)
  if (isInputRange!R && isInputRange!E &&
      isScalarType!(ElementType!E) && isScalarType!(ElementType!R))
{
  alias ElementType!E T;
  while (!r.empty && !find(pattern, cast(T)r.front).empty)
    r.popFront();
}

//----------------------------------------------------------------------------
// Consume the rest of the range.

void drain(R)(ref R r) if (isInputRange!R)
{
  while (!r.empty) r.popFront();
}

//----------------------------------------------------------------------------
// Splits a range into chunks of given length. Doesn't work with narrow
// strings.

struct ByChunk(R) if (!isNarrowString!R)
{
  R rng;
  ulong num;

  this(R r, ulong n) { rng = r; num = n; }

  @property bool empty() { return rng.empty; }

  @property R front() { return rng.take(num); }

  void popFront() { rng = rng.drop(num); }
}

ByChunk!R byChunk(R)(R r, ulong n) { return ByChunk!R(r,n); }


//----------------------------------------------------------------------------

unittest
{
  import std.stdio;

  ubyte[] txt = cast(ubyte[]) "acabacbxyz".dup;
  auto buff = appender!(ubyte[]);

  auto r1 = inputRangeObject(txt);
  assert(!r1.empty);
  r1.drain();
  assert(r1.empty);

  r1 = inputRangeObject(txt);
  r1.munch("abc");
  r1.copy(buff);
  assert(cast(char[])(buff.data) == "xyz");

  buff.clear();

  //txt = cast(ubyte[]) "acabacbxyz".dup;
}

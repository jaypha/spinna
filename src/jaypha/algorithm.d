/*
 * Algorithms
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


module jaypha.algorithm;

import std.algorithm;

template meld(alias fun)
{
  auto meld(A)(A t) //if (isAssociativeArray!A && isSomeString!(KeyType!A))
  {
    return MeldResult!(fun, A)(t);
  }
}

private struct MeldResult(alias F, T:T[U],U)
{
  U[] val;
  T[U] home;
  
  this(T[U] t) { home = t; val = t.keys; }

  @property bool empty() { return (val.length == 0); }
  @property U front() { return F(val[0],home[val[0]]); }
  void popFront() { val = val[1..$]; }
}

unittest
{
  string[string] x = [ "one":"1", "bee":"3", "john":"66" ];

  char[] z;
  auto y = x.meld!((a,b) => (a~b));
  while (!y.empty)
  {
    z ~= y.front;
    y.popFront();
    z ~= ",";
  }
  z = z[0..$-1];

  assert(cast(const(char)[])z == "one1,bee3,john66");
}


T[] diff(T)(T[] primary, T[] secondary)
{
  T[] result = [];

  foreach (t;primary)
  {
    if (!secondary.canFind(t))
      result ~= t;
  }

  return result;
}
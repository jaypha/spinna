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

import std.algorithm, std.typecons, std.range, std.array, std.traits;

//----------------------------------------------------------------------------

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

//----------------------------------------------------------------------------

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

//----------------------------------------------------------------------------

// R1 is input range, R2 is slicable

auto find_split(R1,R2)(ref R1 haystack, R2 needle) //if ((ElementType!R1 == ElementType!R2) && isInputRange!(R1) && hasSlicing!(R2))
{
  alias ElementType!R2 E;
  R2 first_part, second_part;

  while (true)
  {
    if (startsWith(needle, second_part))
    {
      foreach (n; needle[second_part.length .. $])
      {
        if (haystack.empty || haystack.front != n) break;
        second_part ~= n;
        haystack.popFront();
      }
      if (needle.length == second_part.length)
      {
        assert(equal(needle, second_part));
        return tuple(first_part, second_part);
      }
      if (haystack.empty)
        return tuple(first_part~second_part, uninitializedArray!(R2)(0));
      else
      {
        second_part ~= haystack.front;
        haystack.popFront();
      }
    }

    first_part ~= second_part[0];
    second_part = second_part[1..$];
  }
}

unittest
{
  //import std.stdio;
  ubyte[] txt = cast(ubyte[]) "acabacbxyz".dup;

  string haystack = "donabababcbxyz";
  string needle = "ababc";

  auto res = find_split(haystack, needle);
  assert(res[0] == "donab");
  assert(res[1] == "ababc");
  assert(haystack == "bxyz");

  auto res2 = find_split(haystack, needle);
  assert(res2[0] == "bxyz");
  assert(res2[1] == "");
  assert(haystack == "");

  haystack = "asdfjkewu";
  auto res3 = find_split(haystack, "a");
  assert(res3[0] == "");
  assert(res3[1] == "a");
  assert(haystack == "sdfjkewu");
}

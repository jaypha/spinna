//Written in the D programming language
/*
 * Algorithms
 *
 * Copyright 2013 Jaypha
 *
 * Distributed under the Boost Software License, Version 1.0.
 * (See http://www.boost.org/LICENSE_1_0.txt)
 *
 * Authors: Jason den Dulk
 */


module jaypha.algorithm;

public import std.algorithm;
import std.typecons, std.range, std.array, std.traits;

//----------------------------------------------------------------------------
// Map-like algorithm that merges the index and values of an associative
// array.

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
// Returns everything in primary that is not in secondary

T[] diff(T)(T[] primary, T[] secondary)
{
  auto result = appender!(T[])();
  result.reserve(primary.length);

  foreach (t;primary)
  {
    if (!secondary.canFind(t))
      result.put(t);
  }

  return result.data;
}

//----------------------------------------------------------------------------
// Alternative to std.alogrithm.findSplit usable with non-rewindable ranges.
// R1 is input range, R2 is slicable

auto findSplit(R1,R2)(ref R1 haystack, R2 needle) //if ((ElementType!R1 == ElementType!R2) && isInputRange!(R1) && hasSlicing!(R2))
{
  alias ElementType!R2 E;
  R2 firstPart, secondPart;

  while (true)
  {
    if (startsWith(needle, secondPart))
    {
      foreach (n; needle[secondPart.length .. $])
      {
        if (haystack.empty || haystack.front != n) break;
        secondPart ~= n;
        haystack.popFront();
      }
      if (needle.length == secondPart.length)
      {
        assert(equal(needle, secondPart));
        return tuple(firstPart, secondPart);
      }
      if (haystack.empty)
        return tuple(firstPart~secondPart, uninitializedArray!(R2)(0));
      else
      {
        secondPart ~= haystack.front;
        haystack.popFront();
      }
    }

    firstPart ~= secondPart[0];
    secondPart = secondPart[1..$];
  }
}

alias findSplit find_split;


unittest
{
  //import std.stdio;
  ubyte[] txt = cast(ubyte[]) "acabacbxyz".dup;

  string haystack = "donabababcbxyz";
  string needle = "ababc";

  auto res = findSplit(haystack, needle);
  assert(res[0] == "donab");
  assert(res[1] == "ababc");
  assert(haystack == "bxyz");

  auto res2 = findSplit(haystack, needle);
  assert(res2[0] == "bxyz");
  assert(res2[1] == "");
  assert(haystack == "");

  haystack = "asdfjkewu";
  auto res3 = findSplit(haystack, "a");
  assert(res3[0] == "");
  assert(res3[1] == "a");
  assert(haystack == "sdfjkewu");
}

//----------------------------------------------------------------------------
// Similar to std.algorithm.map except that the mapping function is not a
// template parameter

struct rtMap(R,T) if(isInputRange!R)
{
  this(R r, T delegate(ElementType!R) p)
  {
    result = r;
    prepare = p;
    _front = prepare(result.front);
  }

  @property T front() { return _front; }
  @property bool empty() { return result.empty; }
  void popFront()
  {
    result.popFront();
    if (!result.empty)
      _front = prepare(result.front);
  }

  private:
    R result;
    T _front;
    T delegate(ElementType!R) prepare;
}

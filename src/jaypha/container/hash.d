//Written in the D programming language
/*
 * Hash table which can store more than one value for a key
 *
 * Copyright 2009-2014 Jaypha
 *
 * Distributed under the Boost Software License, Version 1.0.
 * (See http://www.boost.org/LICENSE_1_0.txt)
 *
 * Authors: Jason den Dulk
 */

module jaypha.container.hash;


//----------------------------------------------------------------------------

struct Hash(T)

//----------------------------------------------------------------------------
{
  // () operator
  T[] opCall(string i) { return a[i]; }

  // [] operator
  T opIndex(string i) { return a[i][0]; }

  // []= operator
  void opIndexAssign(T v, string i) { a[i] = [v]; }
  void opIndexAssign(T[] v, string i) { a[i] = v; }

  // "in" operator
  T[]* opIn_r(string i) { return (i in a); }

  //--------------------------------------------------------------------------

  @property T[][string] all() { return a; }

  //--------------------------------------------------------------------------

  @property T[string] toArray()
  {
    T[string] ret;
    foreach (s,x;a)
      ret[s] = x[0];
    return ret;
  }

  //--------------------------------------------------------------------------

  @property ulong length() { return a.length; }

  //--------------------------------------------------------------------------

  @property string[] keys() { return a.keys; }
  @property T[][] values() { return a.values; }

  //--------------------------------------------------------------------------

  Hash!(T) rehash() { a.rehash; return this; } // TODO does rehash modify the original array? If not then use the one below.
  //Hash!(T) rehash() { auto p = Hash!(T)(); p.a = a.rehash; return p; }

  //--------------------------------------------------------------------------
  // Deep copy constructor.
  this(this) { foreach (i,v; a) a[i] = v.dup; }

  //--------------------------------------------------------------------------

  void add(string i, T v) { if (!(i in a)) a[i]=[]; a[i] ~= v; }
  void remove(string i) { a.remove(i); }

  //--------------------------------------------------------------------------
  // foreach (v;h)
  int opApply(int delegate(ref T[]) dg)
  {
    int result = 0;
    foreach (v; a)
    {
      result = dg(v);
      if (result) break;
    }
    return result;
  }

  //--------------------------------------------------------------------------
  // foreach (i,v;h)
  int opApply(int delegate(ref string, ref T[]) dg)
  {
    int result = 0;
    foreach (i, v; a)
    {
      result = dg(i, v);
      if (result) break;
    }
    return result;
  }

  //--------------------------------------------------------------------------

  void clear() { a = a.init; }

  //--------------------------------------------------------------------------

  private:
    T[][string] a;
}

//----------------------------------------------------------------------------
// Alias for string based hashes, which are the most common.
 
alias Hash!(string) StrHash;

//----------------------------------------------------------------------------

unittest
{
  import std.stdio;
  
  StrHash a;
  a["one"] = "4";
  assert(a["one"] == "4");
  a.add("two","3");
  a.add("one","5");

  assert(a["one"] == "4");
  assert(a["two"] == "3");
  assert(a("one") == ["4","5"]);

  a["one"] = ["8","9","10"];
  assert(a["one"] == "8");
  assert(a("one") == ["8","9","10"]);
  assert(a.length == 2);
  assert(a("one").length == 3);
}

//----------------------------------------------------------------------------


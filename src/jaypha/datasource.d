//Written in the D programming language
/*
 * Data source traits
 *
 * Copyright (C) 2013 Jaypha
 *
 * Distributed under the Boost Software License, Version 1.0.
 * (See http://www.boost.org/LICENSE_1_0.txt)
 *
 * Authors: Jason den Dulk
 */

module jaypha.datasource;

import std.range;
import std.array;
import std.traits;


enum bool isDataSource(T) = is(typeof(
  (inout int = 0)
  {
    T ds = void;
    ulong sz = ds.length;
    auto x = ds[];
    x = ds[0..1];
    x = ds[0..$];
    x = ds.apply(0,1);
    x = ds.apply(0);
  }
)) && isInputRange!(ReturnType!(T.apply));

template DataSourceElementType(T)
{
  alias ElementType!(ReturnType!(T.apply)) DataSourceElementType;
}



unittest
{
  struct MyDS
  {
    string stuff;

    @property ulong length() { return stuff.length; }

    string opIndex() { return stuff; }
    string opSlice(size_t pos)(ulong s, ulong f) { return stuff[s..f]; }
    auto opDollar(size_t pos)() { return stuff.length; }
    
    string apply(start, limit = 0) { if (limit == 0) return stuff[start..$]; else return stuff[start..start+limit]; }
  }

  static assert(isDataSource!MyDS);
  static assert(is(DataSourceElementType!MyDS == dchar));

  auto ds = MyDS("juju de wooboo");

  assert(ds.apply(3) == "u de wooboo");
  assert(ds.length == 14);
  assert(ds.apply(3,5) == "u de ");
  assert(ds[] == "juju de wooboo");
  assert(da[2..10] == "ju de wo");
}
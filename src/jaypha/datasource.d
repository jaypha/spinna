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

// Basically, it is a data source if it has certian array-like behaviours.
enum bool isDataSource(T: T[]) = true;

enum bool isDataSource(T) = is(typeof(
  (inout int = 0)
  {
    T ds = void;
    ulong sz = ds.length;
    auto x = ds[];
    x = ds[0..1];
    x = ds[0..$];
    bool y = x.empty;
    auto r = x.front;
    x.popFront();
  }
));

template DataSourceElementType(T: T[])
{
  alias T DataSourceElementType;
}

template DataSourceElementType(T)
{
  alias ElementType!(ReturnType!(T.opSlice)) DataSourceElementType;
}



unittest
{
  struct MyDS
  {
    string stuff;

    @property ulong length() { return stuff.length; }

    string opSlice() { return stuff; }
    string opSlice(ulong s, ulong f) { return stuff[s..f]; }
    auto opDollar() { return stuff.length; }
  }

  static assert(isDataSource!MyDS);
  static assert(is(DataSourceElementType!MyDS == dchar));


  auto ds = MyDS("juju de wooboo");

//  assert(ds.apply(3) == "u de wooboo");
  assert(ds.length == 14);
  assert(ds[] == "juju de wooboo");
  assert(ds[2..10] == "ju de wo");
  assert(ds[3..$] == "u de wooboo");
}

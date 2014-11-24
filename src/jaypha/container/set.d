//Written in the D programming language
/*
 * Simple set implementation
 *
 * Copyright 2009-2014 Jaypha
 *
 * Distributed under the Boost Software License, Version 1.0.
 * (See http://www.boost.org/LICENSE_1_0.txt)
 *
 * Authors: Jason den Dulk
 */

module jaypha.container.set;

// Simple collection where each element is unique.

struct Set(T)
{
  void put(T t)
  {
    foreach (e; theSet)
      if (t == e) return;
    
    theSet ~= t;
  }

  ulong size() { return theSet.length; }

  auto range()
  {
    return theSet;
  }

  private:

    T[] theSet;
}

//----------------------------------------------------------------------------
// Like Set, but the elements are ordered, and the set is indexable.

struct OrderedSet(T)
{
  ulong put(T t)
  {
    foreach (i,e; theSet)
      if (t == e) return i;

    theSet ~= t;
    return theSet.length-1;
  }

  ulong size() { return theSet.length; }

  T opIndex(ulong i) { return theSet[i]; }

  auto range()
  {
    return theSet;
  }

  private:

    T[] theSet;
}

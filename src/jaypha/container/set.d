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

struct Set(T)
{
  this() { theSet = []; }

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

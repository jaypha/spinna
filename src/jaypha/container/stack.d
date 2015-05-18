//Written in the D programming language
/*
 * Simple stack.
 *
 * Copyright (C) 2014 Jaypha
 *
 * Distributed under the Boost Software License, Version 1.0.
 * (See http://www.boost.org/LICENSE_1_0.txt)
 *
 * Authors: Jason den Dulk
 */

module jaypha.container.stack;

import std.array;

struct Stack(T)
{
  private:

    T[] q;

  public:

    void put(T t)
    {
      q ~= t;
    }

    @property bool empty() { return q.empty; }
    @property ref T front() { return q[$-1]; }
    void popFront() { q = q[0..$-1]; }

    void clear() { q.length = 0; }
}

unittest
{
  Stack!long stack;

  assert(stack.empty);

  stack.put(5);

  assert(!stack.empty);
  assert(stack.front == 5);

  stack.put(12);

  assert(!stack.empty);
  assert(stack.front == 12);

  stack.popFront();

  assert(!stack.empty);
  assert(stack.front == 5);

  stack.put(3);

  assert(!stack.empty);
  assert(stack.front == 3);

  stack.popFront();

  assert(!stack.empty);
  assert(stack.front == 5);
  
  stack.popFront();

  assert(stack.empty);

  stack.put(3);
  stack.put(12);

  assert(!stack.empty);
  assert(stack.front == 12);

  stack.clear();
  assert(stack.empty);
}

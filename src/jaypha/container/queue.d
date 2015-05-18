//Written in the D programming language
/*
 * Simple queue.
 *
 * Copyright 2009-2014 Jaypha
 *
 * Distributed under the Boost Software License, Version 1.0.
 * (See http://www.boost.org/LICENSE_1_0.txt)
 *
 * Authors: Jason den Dulk
 */

module jaypha.container.queue;

import std.array;

//----------------------------------------------------------------------------
struct Queue(T)
//----------------------------------------------------------------------------
{
  alias Queue!T Q;

  private:

    T[] theQueue;

  public:

    void put(T t)
    {
      theQueue ~= t;
    }

    Q opOpAssign(string str)(T t) if (str == "~")
    {
      theQueue ~= t;
      return this;
    }

    @property bool empty() { return theQueue.empty; }
    @property ref T front() { return theQueue.front(); }
    void popFront() { theQueue.popFront(); }
}

//----------------------------------------------------------------------------

unittest
{
  Queue!long queue;

  assert(queue.empty);

  queue.put(4);

  assert(!queue.empty);
  assert(queue.front == 4);

  queue.put(12);

  assert(queue.front == 4);

  queue.put(8);

  assert(queue.front == 4);

  queue.popFront();

  assert(queue.front == 12);

  queue.put(1);

  assert(queue.front == 12);

  queue.popFront();

  assert(queue.front == 8);

  queue.popFront();

  assert(queue.front == 1);

  queue.popFront();

  assert(queue.empty);
}

//----------------------------------------------------------------------------

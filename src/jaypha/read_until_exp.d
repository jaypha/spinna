
module jaypha.read_until_exp;

import std.traits;
import std.range;
import std.exception;
import std.algorithm;

/*
template ElementType(R)
{
    static if (is(typeof((inout int = 0){ R r = void; return r.front; }()) T))
        alias T ElementType;
    else
        alias void ElementType;
}

@property bool empty(T)(in T[] a) @safe pure nothrow
{
    return !a.length;
}

void popFront(T)(ref T[] a)
{
    a = a[1 .. $];
}

@property ref T front(T)(T[] a)
{
    return a[0];
}
*/

//----------------------------------------------------------------------------
// read_until
//
// An alternative to std.algorithm.until that works with ordinary input
// ranges.

auto read_until(R,E)(ref R r, E sentinel)
  if (isInputRange!R && isInputRange!E &&
      isScalarType!(ElementType!E) && isScalarType!(ElementType!R))
{
  alias ElementType!R T;


//----------------------------------------------------------------------------

struct ReadUntil
{

  //------------------------------------

  bool empty = false;

  //------------------------------------

  @property T front()
  {
    if (idx < length) return sentinel[idx];
    return r.front;
  }

  //------------------------------------

  void popFront()
  {
    if (!empty)
    {
      if (idx < length)
      {
        ++idx;
        if (idx == length)
        {
          idx = length = 0;
          sentinel_check();
        }
      }
      else
      {
        r.popFront();
        enforce(!r.empty);
        sentinel_check();
      }
    }
  }

  //------------------------------------

  void sentinel_check()
  {
    if (r.front != sentinel[0]) return;

    do
    {
      r.popFront();
      enforce(!r.empty);
      ++length;
    } while (length < sentinel.length && r.front == sentinel[length]);

    if (length == sentinel.length)
      empty = true;
  }

  //------------------------------------

  private:
    uint length = 0;
    uint idx = 0;
}

  ReadUntil ru;
  return ru;
}

//----------------------------------------------------------------------------


void main()
{
  ubyte[] txt = cast(ubyte[]) "acabacbxyz".dup;

  ubyte[] buff;

  //auto r1 = inputRangeObject(txt);

  auto u = read_until(txt,"acb");
  while (!u.empty)
  {
    buff ~= u.front;
    u.popFront();
  }
  //u.copy(buff);
  assert(cast(char[])(buff) == "acab");
  assert(cast(char[])txt == "xyz");
  //buff.clear();
  //r1.copy(buff);
  //assert(cast(char[])(buff.data) == "xyz");
}

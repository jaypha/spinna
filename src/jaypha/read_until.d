
module jaypha.read_until;

import std.traits;
import std.range;
import std.exception;
import std.algorithm;


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

  //----------------------------------------------------

  final class ReadUntil
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

  return new ReadUntil();
}

//----------------------------------------------------------------------------

unittest
{
  ubyte[] txt = cast(ubyte[]) "acabacbxyz".dup;

  auto buff = appender!(ubyte[]);

  auto r1 = inputRangeObject(txt);

  auto u = read_until(r1,"acb");
  u.copy(buff);
  assert(cast(char[])(buff.data) == "acab");
  buff.clear();
  r1.copy(buff);
  assert(cast(char[])(buff.data) == "xyz");
}

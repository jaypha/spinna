


module jaypha.range;

import std.algorithm;
import std.range;
import std.traits;
import std.exception;

//----------------------------------------------------------------------------
// munch

void munch(R,E)(ref R r, E pattern)
  if (isInputRange!R && isInputRange!E &&
      isScalarType!(ElementType!E) && isScalarType!(ElementType!R))
{
  alias ElementType!E T;
  while (!r.empty && !find(pattern, cast(T)r.front).empty)
    r.popFront();
}

//----------------------------------------------------------------------------

void drain(R)(ref R r) if (isInputRange!R)
{
  while (!r.empty) r.popFront();
}

//----------------------------------------------------------------------------

bool skip_over_anyway(R)(ref R r, string prefix, bool all_or_nothing = false)
 if (isInputRange!R)
{
  if (r.empty || r.front != prefix[0])
    return false;

  uint i = 0;
  do
  {
    r.popFront();
    ++i;
  } while (i < prefix.length && !r.empty && r.front == prefix[i]);

  if (i == prefix.length) return true;
  enforce(!all_or_nothing);
  return false;
}

//----------------------------------------------------------------------------

unittest
{
  import std.stdio;

  ubyte[] txt = cast(ubyte[]) "acabacbxyz".dup;
  auto buff = appender!(ubyte[]);

  auto r1 = inputRangeObject(txt);
  assert(!r1.empty);
  r1.drain();
  assert(r1.empty);

  r1 = inputRangeObject(txt);
  r1.munch("abc");
  r1.copy(buff);
  assert(cast(char[])(buff.data) == "xyz");

  buff.clear();

  //txt = cast(ubyte[]) "acabacbxyz".dup;
  r1 = inputRangeObject(txt);

  assert(skip_over_anyway(r1, "aca"));
  assert(!skip_over_anyway(r1, "baa"));
  assert(!skip_over_anyway(r1, "xyz"));
  //skip_over_anyway(r1,"cbz",true); // <- should fail
  r1.copy(buff);
  assert(cast(char[])(buff.data) == "cbxyz");
}

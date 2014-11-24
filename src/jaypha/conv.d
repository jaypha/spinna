//Written in the D programming language
/*
 * Conversion routines.
 *
 * Copyright (C) 2013 Jaypha
 *
 * Distributed under the Boost Software License, Version 1.0.
 * (See http://www.boost.org/LICENSE_1_0.txt)
 *
 * Authors: Jason den Dulk
 */

module jaypha.conv;

//----------------------------------------------------------------------------
// Converts an unsigned interger into a hex string.

string bin2hex(uint i)
{
  static immutable char[16] hex = "0123456789ABCDEF";
  char[8] x;
  foreach(j;0..8)
  {
    x[7-j] = hex[i%16];
    i = i >>> 4;
  }
  return x.idup;
}

//----------------------------------------------------------------------------
// Extract the bits from a number and puts them into an aray.
// eg. 01101b => [ 1000b, 100b, 1b ].

T[] bitsToList(T)(T v) if(__traits(isIntegral,T))
{
  assert(v >= 0);
  T c = 1;
  T[] r;

  while (v != 0)
  {
    if (v & 1)
      r ~= c;
    v = v >>> 1;
    c = c << 1;
  }
  return r;
}

//----------------------------------------------------------------------------
// Reduces an array to a single value by or-ing them together.
// TODO explore using std.algorithm.reduce.

T listToBits(T)(T[] list) if(__traits(isIntegral,T))
{
  T bits;

  foreach (l;list)
  {
    assert(l >= 0);
    bits |= l;
  }
  return bits;
}

//----------------------------------------------------------------------------

/+

struct AsUTF16(R) if (isInputRange!R && Unqual(ElementType!R)==ubyte)
{
  R range;

  wchar current;
  bool is_empty = false;

  this(R r, Endian endianness = Endian.bigEndian) { range = r; popFront(); }

  @property bool empty() { return is_empty; }

  @property wchar front() { return current; }

  void popFront()
  {
    if (range.empty)
      is_empty = true;
    else
    {
      ushort a = range.front();
      range.popFront();
      enforce(!range.empty);
      ushort b = range.front();
      range.popFront();
      current = cast (wchar)(a << 8 | b);
    }
  }
}

struct AsUTF8(R) //if (isInputRange!R && Unqual(ElementType!R)==ubyte)
{
  R range;

  this(R r) { range = r; }

  @property bool empty() { return range.empty; }

  @property char front() { return cast(char)range.front; }
  void popFront() { range.popFront(); }
}

+/

unittest
{
  assert(bin2hex(10) == "0000000A");
  assert(bin2hex(0xB4C58A6E) == "B4C58A6E");
  assert(bin2hex(0x8765432)  == "08765432");
  assert(bin2hex(0x4B8DA00C) == "4B8DA00C");
  assert(bitsToList(0x7A) == [ 2, 8, 16, 32, 64 ]);
  assert(listToBits([ 64, 32, 16,  8, 2 ]) == 0x7A);
}

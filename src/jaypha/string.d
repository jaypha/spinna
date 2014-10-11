//Written in the D programming language
/*
 * String utilities
 *
 * Copyright 2013 Jaypha.
 *
 * Distributed under the Boost Software License, Version 1.0.
 * (See http://www.boost.org/LICENSE_1_0.txt)
 *
 * Authors: Jason den Dulk
 */

module jaypha.string;

import std.string;
import std.traits;
import std.uni;
import std.array;
import std.c.string;
import std.algorithm;

//----------------------------------------------------------------------------
// Splits a string into substrings based on a group of possible delimiters.

inout(char)[][] splitUp(inout(char)[] text, inout(char)[] delimiters)
{
  inout(char)[][] result = [];
  ulong start = 0;

  foreach(i; 0..text.length)
    if (indexOf(delimiters, text[i]) != -1)
    {
      result ~= text[start..i];
      start = i+1;
    }
  result ~= text[start..$];

  return result;
}

//----------------------------------------------------------------------------
// Converts a string to camel case.

@trusted pure string toCamelCase(string text, bool first = true)
{
  auto result = appender!string();

  foreach (ch; text)
  {
    if (ch == '_' || ch == ' ')
    {
      first = true;
    }
    else if (first)
    {
      result.put(toUpper(ch));
      first = false;
    }
    else
    {
      result.put(ch);
    }
  }
  return result.data;
}

//----------------------------------------------------------------------------
// Are all cahracter digits?

@safe pure nothrow bool isDigits(string s)
{
  import std.ascii;

  foreach (c; s)
    if (!isDigit(c))
      return false;
  return true;
}

//-----------------------------------------------------------------------------
// A quick and dirty alternative indexOf. Only works with ASCII.

auto altIndexOf(string s, char c)
{
  auto p = cast(char*)memchr(s.ptr, c, s.length);
  return (p?p - s.ptr:s.length);
}


//-----------------------------------------------------------------------------
// Grabs as much of S1, unitl a character is found that is in pattern.
// Returns the first part while setting S1 to the remainder (including the
// found character.

S1 grab(S1, S2)(ref S1 s, S2 pattern)
{
  auto remainder = findAmong(s, pattern);
  scope(exit) s = remainder;
  return s[0..$-remainder.length];
  /*

  size_t j = s.length;
  foreach (i, c; s)
  {
    if (inPattern(c, pattern))
    {
      j = i;
      break;
    }
  }
  scope(exit) s = s[j .. $];
  return s[0 .. j];
  */
}

//----------------------------------------------------------------------------

unittest
{
  assert(toCamelCase("abc_def pip") == "AbcDefPip");
  assert(toCamelCase("xyz_tob", false) == "xyzTob");
  assert(toCamelCase("123_456", false) == "123456");

  auto result = splitUp("to be or not to be", " e");
  assert(result.length == 8);
  assert(result[0] == "to");
  assert(result[1] == "b");
  assert(result[2] == "");
  assert(result[3] == "or");
  assert(result[4] == "not");
  assert(result[5] == "to");
  assert(result[6] == "b");
  assert(result[7] == "");

  string t1 = "to be or not to be";
  auto t = grab(t1, "abc");
  assert(t == "to ");
  assert(t1 == "be or not to be");

  t1 = "abcdefghijklmnop";
  assert(altIndexOf(t1,'f') == 5);
  assert(altIndexOf(t1,'a') == 0);
  assert(altIndexOf(t1,'$') == t1.length);
}

/*
 * String utilities
 *
 * Copyright 2013 Jaypha.
 *
 * Distributed under the Boost Software License, Version 1.0.
 * (See http://www.boost.org/LICENSE_1_0.txt)
 *
 * Authors: Jason den Dulk
 *
 * Written in the D language.
 */

module jaypha.string;

import std.string;
import std.traits;
import std.uni;
import std.array;

//----------------------------------------------------------------------------
// splitup
//
// Splits a string into substrings based on a group of possible delimiters.

inout(char)[][] splitup(inout(char)[] text, inout(char)[] delimiters)
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
// to_camel_case

@trusted pure nothrow immutable(C)[] to_camel_case(C = char)(const(C)[] text, bool first = true)
  if (isSomeChar!C)
{
  immutable(C)[] result;

  foreach (ch; text)
  {
    if (ch == '_' || ch == ' ')
    {
      first = true;
    }
    else if (first)
    {
      result ~= toUpper(ch);
      first = false;
    }
    else
    {
      result ~= ch;
    }
  }
  return result;
}

//----------------------------------------------------------------------------

bool is_digits(string s)
{
  import std.ascii;

  foreach (c; s)
    if (!isDigit(c))
      return false;
  return true;
}

//----------------------------------------------------------------------------

unittest
{
  assert(to_camel_case("abc_def pip") == "AbcDefPip");
  assert(to_camel_case("xyz_tob", false) == "xyzTob");
  assert(to_camel_case("123_456", false) == "123456");

  auto result = splitup("to be or not to be", " e");
  assert(result.length == 8);
  assert(result[0] == "to");
  assert(result[1] == "b");
  assert(result[2] == "");
  assert(result[3] == "or");
  assert(result[4] == "not");
  assert(result[5] == "to");
  assert(result[6] == "b");
  assert(result[7] == "");
}

//Written in the D programming language
/*
 * This module has functions to read/write data to a serialize string.
 *
 * It does not support the ability to read/write objects, but does
 * support arrays and associative arrays.
 *
 * To serialize a value, call "serialize!(Type)(value)".
 *
 * Unserializing is a bit more tricky. You need to know the type before hand
 * and unserialise using it. An alternative would be to use Variant, but I
 * have not got that working.
 *
 * To unserialize a value call "unserialize!(Type)(const(char)[] str)".
 * str will be updated to the remainder of the string and the decoded
 * value is returned.
 *
 * Future direction: Make it all work with ranges, maybe.
 *
 * Copyright 2013 Jaypha
 *
 * Distributed under the Boost Software License, Version 1.0.
 * (See http://www.boost.org/LICENSE_1_0.txt)
 *
 * Authors: Jason den Dulk
 */

module jaypha.io.serialize;

import std.regex;
import std.format;
import std.array;
import std.traits;
import std.string;
import std.conv;
import std.utf;
import std.variant;

//----------------------------------------------------------------------------
//
// serialize
//
//----------------------------------------------------------------------------
//
// Various serialize functions of the general format
// string serialize(T)(T value) where T is a supported type.
// Returns the encoded value.
//
//----------------------------------------------------------------------------

string serialize(T)(T value) if (isSomeChar!T)
{
  char[4] v;
  auto v2 = toUTF8(v,value);
  return format("s%d:%s",v2.length,v2);
}

//----------------------------------------------------------------------------

string serialize(T:bool)(T value)
{
  return value?"b1":"b0";
}

//----------------------------------------------------------------------------

string serialize(T)(T value) if (isIntegral!(T))
{
  return format("i%d",value);
}

//----------------------------------------------------------------------------

string serialize(T)(T value) if (isFloatingPoint!(T))
{
  return format("f%f",value);
}

//----------------------------------------------------------------------------

string serialize(T:T[])(T[] value)
{
  static if (is(Unqual!T == char))
    return format("s%d:%s",value.length,value);
  else static if (is(Unqual!T == wchar) || is(Unqual!T == dchar))
    return serialize!(const(char)[])(toUTF8(value));
  else
  {
    auto x = appender!(string);
    formattedWrite(x,"a%d",value.length);
    foreach (idx,val; value)
      x.put(serialize!(T)(val));
    return x.data;
  }
}

//----------------------------------------------------------------------------

string serialize(T:T[U],U)(T[U] value)
{
  auto x = appender!(string);
  formattedWrite(x,"o%d",value.length);
  foreach (idx,val; value)
  {
    x.put(serialize!(U)(idx));
    x.put(serialize!(T)(val));
  }
  return x.data;
}

//----------------------------------------------------------------------------

string custom_serialize(alias F,T:T[])(T[] value)
{
  auto x = appender!(string);
  formattedWrite(x,"a%d",value.length);
  foreach (idx,val; value)
    x.put(F(val));
  return x.data;
}

//----------------------------------------------------------------------------

string custom_serialize(alias F,T:T[U],U)(T[U] value)
{
  auto x = appender!(string);
  formattedWrite(x,"o%d",value.length);
  foreach (idx,val; value)
  {
    x.put(serialize!(U)(idx));
    x.put(F(val));
  }
  return x.data;
}

//----------------------------------------------------------------------------
// checkLengthTypeStart
//----------------------------------------------------------------------------
// Used to parse the start of s, a and o types. Returns the extracted length.
//----------------------------------------------------------------------------

uint check_length_type_start(ref const(char)[] str, dchar type)
{
  if (str.length == 0 || str[0] != type)
    throw new Exception(format("Malformed serialize string. Expecting '%c', got %s",type,str));

  auto m = match(str[1..$],php_z_uint);
  if (!m)
    throw new Exception(format("Malformed serialize string. Expecting integer, got %s",str));

  str = str[m.hit.length+1..$];
  return to!uint(m.hit);
}

//----------------------------------------------------------------------------
//
// unserialize
//
//----------------------------------------------------------------------------
//
// Various unserialize functions of the general format
// T unserialize(T)(ref const(char)[] str) where T is a supported type.
// Returns the decoded value, and str is updated to the remainder of the
// string.
//
//----------------------------------------------------------------------------

enum php_z_int = ctRegex!(r"^-?\d+");
enum php_z_uint = ctRegex!(r"^\d+");
enum php_z_float = ctRegex!(r"^-?\d+(\.\d+)?((E|e)(\+|-)?\d+)?");

T unserialize(T:bool)(ref const(char)[] str)
{
  scope(success) { str = str[2..$]; }
  if (str.length <2) throw new Exception(format("Malformed serialize string. Expecting \"b0\"/\"b1\", got \"%s\"",str));
  if (str[0..2] == "b1") return true;
  else if (str[0..2] == "b0") return false;
  else throw new Exception(format("Malformed serialize string. Expecting \"b0\"/\"b1\", got \"%s\"",str[0..2]));
}

//----------------------------------------------------------------------------

T unserialize(T)(ref const(char)[] str) if (isIntegral!T)
{
  if (str[0] != 'i')
    throw new Exception(format("Malformed serialize string. Expecting 'i', got %s",str));

  auto m = match(str[1..$],php_z_int);
  if (!m)
    throw new Exception(format("Malformed serialize string. Expecting integer, got %s",str));

  const(char)[] val = m.hit;
  
  str = str[val.length+1..$];
  return to!T(val);
}

//----------------------------------------------------------------------------

T unserialize(T)(ref const(char)[] str) if (isFloatingPoint!T)
{
  if (str[0] != 'f')
    throw new Exception(format("Malformed serialize string. Expecting 'f', got %s",str));

  auto m = match(str[1..$],php_z_float);
  if (!m)
    throw new Exception(format("Malformed serialize string. Expecting float, got %s",str));

  const(char)[] val = m.hit;
  
  str = str[val.length+1..$];
  return to!T(val);
}

//----------------------------------------------------------------------------

T[] unserialize(T:T[])(ref const(char)[] str)
{
  static if (isSomeChar!T)
  {
    // string values.

    auto len = check_length_type_start(str, 's');

    if (str[0] != ':')
      throw new Exception(format("Malformed serialize string. Expecting ':', got %s",str));

    if (str.length < len)
      throw new Exception(format("Malformed serialize string. Expecting string of length %d, got %s",len,str));

    auto s = str[1..len+1];
    str = str[len+1..$];

    static if (is(T == immutable))
      return s.idup;
    else static if (is(T == const))
      return s.idup;
    else
      return s.dup;
  }
  else
  {
    // ordinary arrays
    auto len = check_length_type_start(str, 'a');
    
    T[] va;
    for (int i=0; i< len; ++i)
      va ~= unserialize!(T)(str);
    return va;
  }
}

//----------------------------------------------------------------------------

T[U] unserialize(T:T[U],U)(ref const(char)[] str)
{
  auto len = check_length_type_start(str, 'o');

  T[U] va;
  for (int i=0; i< len; ++i)
  {
    U v = unserialize!(U)(str);
    va[v] = unserialize!(T)(str);
  }
  return va;
}

//----------------------------------------------------------------------------
// Allows custom unserialize functions to be used.
.
T[] custom_unserialize(T:T[])(ref const(char)[] str)
{
  auto len = check_length_type_start(str, 'a');
  
  T[] va;
  for (int i=0; i< len; ++i)
    va ~= unserialize!(T)(str);
  return va;
}

//----------------------------------------------------------------------------
// Allows custom unserialize functions to be used.

T[U] custom_unserialize(alias F,T:T[U],U)(ref const(char)[] str)
{
  auto len = check_length_type_start(str, 'o');

  T[U] va;
  for (int i=0; i< len; ++i)
  {
    U v = unserialize!(U)(str);
    va[v] = F(str);
  }
  return va;
}

//----------------------------------------------------------------------------

/*
 * Will unserialize a general string, but associative arrays can only have
 * simple types for keys, and all keys in an associative array must be of the
 * same type.
 */

Variant unserialize(V:Variant)(ref const(char)[] str)
{
  switch (str[0])
  {
    case 'b':
      return Variant(unserialize!(bool)(str));
    case 'i':
      return Variant(unserialize!(long)(str));
    case 'f':
      return Variant(unserialize!(double)(str));
    case 's':
      return Variant(unserialize!(string)(str));
    case 'a':
      auto len = check_length_type_start(str, 'a');

      Variant[] va;
      foreach (i; 0..len)
      {
        va ~= unserialize!(Variant)(str);
      }
      return Variant(va);
    case 'o':
      auto leno = check_length_type_start(str, 'o');
      switch (str[0])
      {
        case 'b':
          return Variant(unserializeV!(bool)(str,leno));
        case 'i':
          return Variant(unserializeV!(long)(str,leno));
        case 'f':
          return Variant(unserializeV!(double)(str,leno));
        case 's':
          return Variant(unserializeV!(string)(str,leno));
        default:
          throw new Exception(format("Serialize type '%c' not allowed as keys",str[0]));
      }
    default:
      throw new Exception(format("Unknown serialize type '%c'",str[0]));
  }
}

//----------------------------------------------------------------------------

Variant[T] unserializeV(T)(ref const(char)[] str, uint len)
{
  Variant[T] vaa;
  foreach (j; 0..len)
  {
    auto v = unserialize!(T)(str);
    vaa[v] = unserialize!(Variant)(str);
  }
  return vaa;
}

//----------------------------------------------------------------------------

unittest
{
  // Some alias to help make code more legible (and less bugprone).

  alias const(char)[] cstring;
  alias char[] mstring;

  import std.stdio;
  /* Caution, with associative arrays, the order is not neccessarily the same
   * as given. */
  assert(serialize!(bool)(true) == "b1");
  assert(serialize!(bool)(false) == "b0");

  assert(serialize!(int)(42) == "i42");
  assert(serialize!(int)(33) == "i33");
  assert(serialize!(uint)(12) == "i12");
  assert(serialize!(ubyte)(16) == "i16");
  assert(serialize!(ulong)(183) == "i183");
  assert(serialize!(float)(2.5) == "f2.500000");
  assert(serialize!(float)(.5) == "f0.500000");
  assert(serialize!(int)(-101) == "i-101");
  
  mstring ss = "xyz".dup;
  assert(serialize!(cstring)("abc") == "s3:abc");
  assert(serialize!(cstring)("abc\"xf\nl") == "s8:abc\"xf\nl");
  assert(serialize!(cstring)(ss) == "s3:xyz");
  assert(serialize!(mstring)(ss) == "s3:xyz");
  //assert(serialize!string(ss) == "s3:xyz");

  int[] x = [1,2,3];
  cstring x_s = serialize!(int[])(x);
  assert(x_s == "a3i1i2i3",x_s);

  int[cstring] y;
  y["a"] = 1;
  y["b"] = 2;
  cstring y_s = serialize!(int[cstring])(y);
  assert(y_s == `o2s1:ai1s1:bi2`,y_s);

  mstring[cstring] z;
  z["a"] = "x1".dup;
  z["b"] = "y2".dup;
  z["c"] = "z3".dup;
  cstring z_s = serialize!(mstring[cstring])(z);
  
  assert(z_s == `o3s1:as2:x1s1:bs2:y2s1:cs2:z3`,z_s);

  cstring[cstring] zc;
  zc["a"] = "x1";
  zc["b"] = "y2";
  zc["c"] = "z3";
  cstring zc_s = serialize!(cstring[cstring])(zc);
  assert(zc_s == `o3s1:as2:x1s1:bs2:y2s1:cs2:z3`,zc_s);

  cstring[cstring] zi;
  zi["a"] = "x1";
  zi["b"] = "y2";
  zi["c"] = "z3";
  cstring zi_s = serialize!(cstring[cstring])(zi);
  assert(zi_s == `o3s1:as2:x1s1:bs2:y2s1:cs2:z3`, zi_s);

  int[][] td = [[1,2,3],[4,5,6,10],[7,8,9]];
  cstring td_s = serialize!(int[][])(td);
  assert(td_s == "a3a3i1i2i3a4i4i5i6i10a3i7i8i9",td_s);

  int[cstring] tcd1;
  tcd1["a"] = 1;
  tcd1["b"] = 2;
  tcd1["c"] = 3;

  int[cstring] tcd2;
  tcd2["d"] = 4;
  tcd2["e"] = 5;
  tcd2["f"] = 6;

  int[cstring][] tcd = [ ["a":1,"b":2,"c":3], ["d":4,"e":5,"f":6] ];
//  tcd ~= tcd1;
  //tcd ~= tcd2;

  cstring tcd_s = serialize!(int[cstring][])(tcd);
  // AA! assert(tcd_s == `a2o3s1:bi2s1:ai1s1:ci3o3s1:fi6s1:ei5s1:di4`,tcd_s);

  cstring str = "b0b1xx";
  assert(unserialize!(bool)(str) == false);
  assert(unserialize!(bool)(str) == true);
  assert(str == "xx");

  str = "a23s241o13yy";
  assert(check_length_type_start(str,'a') == 23);
  assert(check_length_type_start(str,'s') == 241);
  assert(check_length_type_start(str,'o') == 13);
  assert(str == "yy");

  str = "s5:abcdefg";
  assert(unserialize!(mstring)(str) == "abcde");
  assert(str == "fg");

  str = "s3:2bcs4:defg";
  assert(unserialize!(const(char)[])(str) == "2bc");
  assert(unserialize!(string)(str) == "defg");
  assert(str == "");

  str = "i15f2.6i-22i00f-1e5zz";
  assert(unserialize!(int)(str) == 15);
  auto f = unserialize!(float)(str);
  assert(f == 2.6f, to!string(f));
  assert(unserialize!(long)(str) == -22);
  assert(unserialize!(uint)(str) == 0);
  auto d = unserialize!(double)(str);
  assert(d == -100000.0, to!string(d));
  assert(str == "zz");

  assert(unserialize!(int[])(x_s) == x);
  assert(unserialize!(int[][])(td_s) == td);

  auto y_uns = unserialize!(int[cstring])(y_s);
  assert(y_uns.length == 2);
  assert("a" in y_uns);
  assert("b" in y_uns);
  assert(y_uns["a"] == 1);
  assert(y_uns["b"] == 2);
  //assert(y_uns == y);    This doesn't work for some reason.

  auto z_uns = unserialize!(mstring[cstring])(z_s);
  assert(z_uns.length == 3);
  assert("a" in z_uns);
  assert("b" in z_uns);
  assert("c" in z_uns);
  assert(z_uns["a"] == "x1");
  assert(z_uns["b"] == "y2");
  assert(z_uns["c"] == "z3");

  auto tcd_uns = unserialize!(int[cstring][])(tcd_s);
  assert(tcd_uns.length == 2);
  auto tcd1_uns = tcd_uns[0];
  assert(tcd1_uns.length == 3);
  assert("a" in tcd1_uns);
  assert("b" in tcd1_uns);
  assert("c" in tcd1_uns);
  assert(tcd1_uns["a"] == 1);
  assert(tcd1_uns["b"] == 2);
  assert(tcd1_uns["c"] == 3);
  auto tcd2_uns = tcd_uns[1];
  assert(tcd2_uns.length == 3);
  assert("d" in tcd2_uns);
  assert("e" in tcd2_uns);
  assert("f" in tcd2_uns);
  assert(tcd2_uns["d"] == 4);
  assert(tcd2_uns["e"] == 5);
  assert(tcd2_uns["f"] == 6);


  cstring tcd_ss = "a2o3s1:ai1s1:bi2s1:ci3o3s1:di4s1:ei5s1:fi6";
  auto tcd_v = unserialize!(Variant)(tcd_ss);
  assert(tcd_v.type() == typeid(Variant[]));
  assert(tcd_v.length == 2);
  auto tcd1_v = tcd_v[0];
  assert(tcd1_v.length == 3);
  assert(tcd1_v.type() == typeid(Variant[string]));
  auto tcd1_vn = tcd1_v.get!(Variant[string]);
  assert("a" in tcd1_vn);
  assert("b" in tcd1_vn);
  assert("c" in tcd1_vn);
  assert(tcd1_v["a"] == 1);
  assert(tcd1_v["b"] == 2);
  assert(tcd1_v["c"] == 3);
  auto tcd2_v = tcd_v[1];
  assert(tcd2_v.length == 3);
  assert(tcd2_v.type() == typeid(Variant[string]));
  auto tcd2_vn = tcd2_v.get!(Variant[string]);
  assert("d" in tcd2_vn);
  assert("e" in tcd2_vn);
  assert("f" in tcd2_vn);
  assert(tcd2_v["d"] == 4);
  assert(tcd2_v["e"] == 5);
  assert(tcd2_v["f"] == 6);


}

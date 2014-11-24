//Written in the D programming language
/*
 * Encodes HTML entities.
 *
 * Copyright (C) 2014 Jaypha
 *
 * Distributed under the Boost Software License, Version 1.0.
 * (See http://www.boost.org/LICENSE_1_0.txt)
 *
 * Authors: Jason den Dulk
 */


module jaypha.html.entity;

import std.array;
import std.string;
import std.traits;
import std.range;

//-----------------------------------------------------------------------------
// Encodes any character into an HTML entity.

immutable(C)[] encode(C = char)(dchar c) if (isSomeChar!C)
{
  return format("&#%d;",c);
}

//-----------------------------------------------------------------------------
// Encodes only special chars. All others are retuned as is.

immutable(C)[] encodeSpecial(C = char)(dchar c) if (isSomeChar!C)
{
  // We use #39 instead of apos because IE does not handle it properly.
  immutable(C)[][dchar] mkchars = [ '"': "&quot;", '\'': "&#39;", '&' : "&amp;", '<' : "&lt;", '>' : "&gt;" ];

  debug
  {
    static if (is (C : char)) assert(cast(uint)c <= 0xFF);
    else static if (is (C : wchar)) assert(cast(uint)c <= 0xFFFF);
  }

  if (c in mkchars) return mkchars[c];
  else return [cast(C)c];
}

//-----------------------------------------------------------------------------
// Encodes a string, converting only special HTML characters.

S encodeSpecial(S)(S s) if (isSomeString!S)
{
  alias ElementEncodingType!S C;

  auto buf = appender!S;
  foreach (C c; s) // Do not decode
  {
    // Passing code units is OK as special chars are all ASCII.
    buf.put(encodeSpecial(c));  
  }
  return buf.data;
}

//-----------------------------------------------------------------------------

unittest
{
  import std.algorithm;

  assert(encodeSpecial('"') == "&quot;"c);

  //encodeSpecial('\u4f3e'); <- should fail.

  assert(encodeSpecial!(wchar)('"') == "&quot;"w);
  assert(encodeSpecial!(wchar)('\u4f3e') == "\u4f3e"w);
  assert(encodeSpecial!(dchar)('"') == "&quot;"d);

  assert(encodeSpecial('&') == "&amp;");
  assert(encodeSpecial('<') == "&lt;");
  assert(encodeSpecial('>') == "&gt;");
  assert(encodeSpecial('\'') == "&#39;");
  assert(encodeSpecial('a') == "a");
  assert(encodeSpecial('$') == "$");

  assert(encode('A') == "&#65;");
  assert(encode('\u4f3e') == "&#20286;");

  assert(encodeSpecial("to \u4f3e quote \"abc\" is > quoting 'a','b','c' & < not quoting.") == "to \u4f3e quote &quot;abc&quot; is &gt; quoting &#39;a&#39;,&#39;b&#39;,&#39;c&#39; &amp; &lt; not quoting.");

  // range style.
  assert(`a"&>b`.map!(encodeSpecial).join() == "a&quot;&amp;&gt;b");
}
/*
 * Encodes HTML entities.
 *
 * Copyright 2014 Jaypha
 *
 * Distributed under the Boost Software License, Version 1.0.
 * (See http://www.boost.org/LICENSE_1_0.txt)
 *
 * Authors: Jason den Dulk
 *
 * Written in the D programming language.
 */


module jaypha.html.entity;

import std.array;
import std.string;
import std.traits;

//-----------------------------------------------------------------------------
// Encodes any character into an HTML entity.

immutable(C)[] encode(C = char)(dchar c) if (isSomeChar!C)
{
  return format("&#%d;",c);
}

//-----------------------------------------------------------------------------
// Encodes only special chars. All others are retuned as is.

immutable(C)[] encode_special(C = char)(dchar c) if (isSomeChar!C)
{
  // We use #39 instead of apos because IE does not handle it properly.
  immutable C[][dchar] mkchars = [ '"': "&quot;", '\'': "&#39;", '&' : "&amp;", '<' : "&lt;", '>' : "&gt;" ];

  static if (is (C : char)) assert(cast(uint)c <= 0xFF);
  else static if (is (C : wchar)) assert(cast(uint)c <= 0xFFFF);

  if (c in mkchars) return mkchars[c];
  else return [cast(C)c];
}

//-----------------------------------------------------------------------------
// Encodes a string, converting only special HTML characters.

immutable(C)[] encode_special(C)(const(C)[] s) if (isSomeChar!C)
{
  auto buf = appender!(immutable(C)[]);
  foreach (C c; s) // Preserve encoding
  {
    // Passing code units is OK as special chars are always ASCII.
    buf.put(encode_special!C(c));  
  }
  return buf.data;
}

//-----------------------------------------------------------------------------

unittest
{
  import std.algorithm;

  assert(encode_special('"') == "&quot;"c);
  //encode_special('\u4f3e'); <-- supposed to fail
  assert(encode_special!(wchar)('"') == "&quot;"w);
  assert(encode_special!(wchar)('\u4f3e') == "\u4f3e"w);
  assert(encode_special!(dchar)('"') == "&quot;"d);

  assert(encode_special('&') == "&amp;");
  assert(encode_special('<') == "&lt;");
  assert(encode_special('>') == "&gt;");
  assert(encode_special('\'') == "&#39;");
  assert(encode_special('a') == "a");
  assert(encode_special('$') == "$");

  assert(encode('A') == "&#65;");
  assert(encode('\u4f3e') == "&#20286;");

  assert(encode_special("to \u4f3e quote \"abc\" is > quoting 'a','b','c' & < not quoting.") == "to \u4f3e quote &quot;abc&quot; is &gt; quoting &#39;a&#39;,&#39;b&#39;,&#39;c&#39; &amp; &lt; not quoting.");

  // range style.
  assert(`a"&>b`.map!(encode_special).join() == "a&quot;&amp;&gt;b");
}
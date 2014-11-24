//Written in the D programming language
/*
 * A bunch of aliases to make typing easier.
 *
 * Copyright 2013 Jaypha
 *
 * Distributed under the Boost Software License, Version 1.0.
 * (See http://www.boost.org/LICENSE_1_0.txt)
 *
 * Authors: Jason den Dulk
 */

module jaypha.types;

import std.range;
public import std.traits;

//-----------------------------------------------------------------------------

alias const(char) cchar;
alias const(dchar) cdchar;

alias const(char)[] cstring;
alias const(dchar)[] cdstring;

alias char[] mstring;
alias dchar[] mdstring;

//-----------------------------------------------------------------------------

alias string[string] strstr;

alias immutable(ubyte)[] ByteArray;

//-----------------------------------------------------------------------------

enum isByteRange(R) = (isInputRange!(R) && is(ElementType!(R) : ubyte));

//-----------------------------------------------------------------------------
// UTF encoding based on D type.

/+
template utfEnc(S) if (isSomeString!S || isSomeChar!S)
{
  static if (is(S == string) || is(S == char))
    enum utfEnc = "UTF-8";
  else static if (is(S == wstring) || is(S == wchar))
    enum utfEnc = "UTF-16";
  else
    enum utfEnc = "UTF-32";
}
+/

enum utfEnc(C:char) = "UTF-8";
enum utfEnc(C:wchar) = "UTF-16";
enum utfEnc(C:dchar) = "UTF-32";
enum utfEnc(S:string) = "UTF-8";
enum utfEnc(S:wstring) = "UTF-16";
enum utfEnc(S:dstring) = "UTF-32";

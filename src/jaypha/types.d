/*
 * A bunch of aliases to make typing easier.
 *
 * Copyright 2013 Jaypha
 *
 * Distributed under the Boost Software License, Version 1.0.
 * (See http://www.boost.org/LICENSE_1_0.txt)
 *
 * Authors: Jason den Dulk
 *
 * Written in the D programming language.
 */

module jaypha.types;

import std.range;

alias const(char) cchar;
alias const(dchar) cdchar;

alias const(char)[] cstring;
alias const(dchar)[] cdstring;

alias char[] mstring;
alias dchar[] mdstring;

alias string[string] strstr;

template isByteRange(R)
{
  enum isByteRange = (isInputRange!(R) && is(ElementType!(R) : ubyte));
}

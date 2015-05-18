//Written in the D programming language
/*
 * Formatted output for output ranges.
 *
 * Distributed under the Boost Software License, Version 1.0.
 * (See http://www.boost.org/LICENSE_1_0.txt)
 *
 * Authors: Jason den Dulk
 *
 * Written in the D language.
 */

/*
 * I use print instead of write to avoid conflicts with std.stdio, but
 * otherwise they should function the same.
 *
 * Most of the implementation is ripped off from Phobos.
 */

module jaypha.io.print;

import std.traits;
import std.conv;

void print(Writer,S...)(Writer w, S args)
{
  foreach (arg; args)
  {
    alias typeof(arg) A;
    static if (is(A == enum))
    {
      std.format.formattedWrite(w, "%s", arg);
    }
    else static if (isSomeString!A)
    {
      w.put(arg);
    }
    else static if (isIntegral!A)
    {
      w.put(to!string(arg));
    }
    else static if (isBoolean!A)
    {
      w.put(arg ? "true" : "false");
    }
    else static if (isSomeChar!A)
    {
      w.put(arg);
    }
    else static if (__traits(compiles,arg.copy(w)))
    {
      arg.copy(w);
    }
    else static if (__traits(compiles,to!string(arg)))
    {
      w.put(to!string(arg));
    }
    else
    {
      // Most general case
      std.format.formattedWrite(w, "%s", arg);
    }
  }
}

void println(Writer,S...)(Writer w, S args)
{
  w.print(args, '\n');
}

void printf(Writer,Char, A...)(Writer w, in Char[] fmt, A args)
{
  std.format.formattedWrite(w, fmt, args);
}

void printfln(Writer,Char, A...)(Writer w, in Char[] fmt, A args)
{
  std.format.formattedWrite(w, fmt, args);
  w.put('\n');
}


unittest
{
  import std.array;

  auto napp = appender!(const(char)[])();

  auto d = "for".dup;

  napp.print("ab",5, true,'g');
  auto ss = napp.data;
  assert(napp.data == "ab5trueg");
  napp.print("xyz\n");
  assert(napp.data == "ab5truegxyz\n");
  napp.printf("b%smat",d);
  assert(napp.data == "ab5truegxyz\nbformat");
  napp.printfln("a %d format",10);
  assert(napp.data == "ab5truegxyz\nbformata 10 format\n");
  napp.println();
  assert(napp.data == "ab5truegxyz\nbformata 10 format\n\n");
}

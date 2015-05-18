//Written in the D programming language
/*
 * Simple object oriented output stream library.
 *
 * Copyright 2013 Jaypha
 *
 * Distributed under the Boost Software License, Version 1.0.
 * (See http://www.boost.org/LICENSE_1_0.txt)
 *
 * Authors: Jason den Dulk
 */

module jaypha.io.outputstream;

import std.range;
import std.traits;
import std.conv;
import std.format;
import std.utf;

//----------------------------------------------------------------------------

interface OutputStream
{
  void put(dchar c);

  void put(const(char)[] s);
  void put(const(wchar)[] s);
  void put(const(dchar)[] s);
}

//----------------------------------------------------------------------------

class OutputRangeStream(R) : OutputStream
  if (isOutputRange!(R,dchar))
{
  R or;
  this(ref R or) { this.or = or; }

  override void put(const(char)[] s)
  {
    static if (isOutputRange!(R,const(char)[]))
      or.put(s);
    else
      foreach (c;s) or.put(c);
  }

  override void put(dchar c)
  {
    or.put(c);
  }

  override void put(const(wchar)[] s)
  {
    static if (isOutputRange!(R,const(wchar)[]))
      or.put(s);
    else static if (isOutputRange!(R,const(char)[]))
      or.put(toUTF8(s));
    else
      foreach (c;s) or.put(c);
  }

  override void put(const(dchar)[] s)
  {
    static if (isOutputRange!(R,const(dchar)[]))
      or.put(s);
    else static if (isOutputRange!(R,const(char)[]))
      or.put(toUTF8(s));
    else
      foreach (c;s) or.put(c);
  }
}

//----------------------------------------------------------------------------

OutputRangeStream!R outputRangeStream(R)(ref R r)
{
  return new OutputRangeStream!R(r);
}

//----------------------------------------------------------------------------

class TextOutputStream : OutputStream
{
  OutputStream stream;
  
  this(OutputStream stream) { this.stream = stream; }

  override void put(dchar c) { stream.put(c); }

  override void put(const(char)[] s)  { stream.put(s); }
  override void put(const(wchar)[] s) { stream.put(s); }
  override void put(const(dchar)[] s) { stream.put(s); }

  final TextOutputStream print(S...)(S args)
  {
    foreach (arg; args)
    {
      alias typeof(arg) A;
      static if (is(A == enum))
      {
        formattedWrite(stream, "%s", arg);
      }
      else static if (isSomeString!A)
      {
        stream.put(arg);
      }
      else static if (isIntegral!A)
      {
        stream.put(to!string(arg));
      }
      else static if (isBoolean!A)
      {
        stream.put(arg ? "true" : "false");
      }
      else static if (isSomeChar!A)
      {
        stream.put(arg);
      }
      else static if (__traits(compiles,arg.copy(this)))
      {
        arg.copy(this);
      }
      else static if (__traits(compiles,to!string(arg)))
      {
        stream.put(to!string(arg));
      }
      else
      {
        formattedWrite(stream, "%s", arg);
      }
    }
    return this;
  }

  final TextOutputStream println(S...)(S args)
  {
    print(args);
    stream.put('\n');
    return this;
  }

  final TextOutputStream eoln()
  {
    stream.put('\n');
    return this;
  }

  final TextOutputStream printf(A...)(in const(char[]) fmt, A args)
  {
    formattedWrite(stream, fmt, args);
    return this;
  }

  final TextOutputStream printfln(A...)(in const(char[]) fmt, A args)
  {
    formattedWrite(stream, fmt, args);
    stream.put('\n');
    return this;
  }
}

//----------------------------------------------------------------------------

TextOutputStream textOutputStream(R)(ref R r)
{
  return new TextOutputStream(new OutputRangeStream!R(r));
}

//----------------------------------------------------------------------------

deprecated class TextBuffer(S = string) : TextOutputStream if (isSomeString!S)
{
  Appender!S buffer;

  this() { buffer = appender!S(); super(outputRangeStream(buffer)); }

  @property S data() { return buffer.data; }
}

//----------------------------------------------------------------------------

unittest
{
  // TODO: test dchar and utf32.

  import std.array;
  import std.stdio;

  auto b = appender!string();

  auto bo = outputRangeStream(b);
  auto o = new TextOutputStream(bo);

  auto d = "for".dup;

  o.print("ab",5, true,'g');
  assert(b.data == "ab5trueg");
  o.print("xyz\n");
  assert(b.data == "ab5truegxyz\n");
  o.printf("b%smat",d);
  assert(b.data == "ab5truegxyz\nbformat");
  o.printfln("a %d format",10);
  assert(b.data == "ab5truegxyz\nbformata 10 format\n");
  o.println();
  assert(b.data == "ab5truegxyz\nbformata 10 format\n\n");
  o.eoln();
  assert(b.data == "ab5truegxyz\nbformata 10 format\n\n\n");

  auto buffer = appender!string();

  auto tb = textOutputStream(buffer);
  tb.print("hello there");

  assert(buffer.data == "hello there");
}

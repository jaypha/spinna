//Written in the D programming language
/*
 * byLines for input ranges.
 *
 * Distributed under the Boost Software License, Version 1.0.
 * (See http://www.boost.org/LICENSE_1_0.txt)
 *
 * Authors: Jason den Dulk
 */

module jaypha.io.lines;

import std.range;
import std.traits;



struct Lines(IRange) if (isInputRange!IRange && isSomeChar!(ElementType!IRange))
{
  alias ElementType!IRange Char;

  private:
    IRange r;
    Char[] line;

  public:
    bool empty = false;
    string eoln;

  this(IRange _r) { r = _r; popFront(); }

  void popFront()
  {
    assert(!empty);
    if (r.empty)
      empty =true;
    else
    {
      auto napp = appender!(Char[])();

      Char[] ln;
      while (!r.empty && r.front != '\n')
      {
        napp.put(r.front);
        r.popFront();
      }
      if (!r.empty) r.popFront();
      ln = napp.data;
      if (ln.length > 0 && ln[ln.length-1] == '\r')
      {
        eoln = "\r\n";
        line = ln[0..$-1];
      }
      else
      {
        eoln = "\n";
        line = ln;
      }
    }
  }

  @property Char[] front()
  {
    return line;
  }
}

unittest
{
  import std.conv;
  
  // Detect if D behaviour changes.

  assert("" !is null);
  assert([] is null);


  char[] a = "abc".dup;
  assert(a[0..0] !is null);
  assert(a[0..0].length == 0);
  a.length = 0;
  assert(a !is null);

  // Ripped off from Phobos.
  void test(string txt, string[] witness)
  {
    //writeln("testing '",txt,"'");
    auto r1 = inputRangeObject(txt);

    static assert(isInputRange!(typeof(r1)));
    static assert(is(typeof(r1) : InputRange!(dchar)));

    auto lines = new Lines!(typeof(r1))(r1);
    uint i;
    //*
    while (!lines.empty)
    {
      assert(i<witness.length, text(i, ">=", witness.length));
      //writeln("str: '",lines.front,"'");
      assert(to!string(lines.front) == witness[i++]);
      lines.popFront();
    }
    /*/
    foreach (line; lines)
    {
      assert(i<witness.length, text(i, ">=", witness.length));
      assert(to!string(line) == witness[i++]);
    }
    /**/
    assert(i == witness.length, text(i, " != ", witness.length));
  }

  test("", null);
  test("\n", [ "" ]);
  test("asd\ndef\nasdf", [ "asd", "def", "asdf" ]);
  test("asd\ndef\nasdf\n", [ "asd", "def", "asdf" ]);
  test("asd\n\nasdf\n", [ "asd", "", "asdf" ]);
  test("asd\r\ndef\r\nasdf\r\n", [ "asd", "def", "asdf" ]);
  test("asd\r\n\r\nasdf\r\n", [ "asd", "", "asdf" ]);
}


module test_main;

import std.stdio;
import std.typecons;
import std.range;
import std.array;

import Backtrace = backtrace.backtrace;

import jaypha.types;

import jaypha.io.output_stream;

import jaypha.io.serialize;

import test_auth;
import test_router;
import test_dialog;

struct WriteOut
{
  void put(const(dchar) d) { write(d); }
  void put(const(char)[] s) { write(s); }
  void put(const(wchar)[] s) { write(s); }
  void put(const(dchar)[] s) { write(s); }
}

static this()
{
  Backtrace.install(stderr);
}

void main(string[] args)
{
  WriteOut writer;

/*
  static if (isOutputRange!(WriteOut,const(wchar)[]))
    writeln("Writeout is an OR of wchar[]");


  auto buf = appender!(char[])();
  auto bos = new TextOutputStream(output_range_stream(buf));

  auto page = new HtmlElement();
  auto inner = new HtmlElement("p");
  inner.add("hello");
  page.add(inner);
  page.copy(bos);
  writeln(buf.data);
  buf.clear();
  writeln();
*/
  test_authorisation();
  test_routr();
  dialog_test(writer);
}

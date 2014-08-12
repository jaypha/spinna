/*
 * Basic Components for building output content.
 *
 * Copyright 2013 Jaypha
 *
 * Distributed under the Boost Software License, Version 1.0.
 * (See http://www.boost.org/LICENSE_1_0.txt)
 *
 * Authors: Jason den Dulk
 *
 * Written in the D language.
 */

module jaypha.spinna.pagebuilder.component;

public import jaypha.types;
public import jaypha.io.output_stream;
import jaypha.embed;

public import jaypha.html.entity;
import std.algorithm;
import std.array;

//-----------------------------------------------------------------------------

interface Component
{
  void copy(TextOutputStream output);
}

//-----------------------------------------------------------------------------

string to_string(Component component)
{
  auto buffer = new TextBuffer!string();
  component.copy(buffer);
  return buffer.data;
}

//-----------------------------------------------------------------------------

class TextComponent : Component
{
  string text;
  
  this(string _text = null) { text = _text; }
  
  override void copy(TextOutputStream output)
  {
    output.print(text);
  }
}

//-----------------------------------------------------------------------------

class Composite : Component
{
  Composite add(const(char)[] t) { content.put(new TextComponent(t.idup)); return this; }
  Composite add(Component o) { content.put(o); return this; }

  @property ulong length() { return content.data.length; }

  override void copy(TextOutputStream output)
  {
    foreach (i; content.data)
      i.copy(output);
  }

  private Appender!(Component[]) content;
}

//-----------------------------------------------------------------------------

Composite wrap(Composite wrapper, Composite target)
{
  wrapper.content.put(target.content.data);
  target.content.clear();
  target.content.put(wrapper);
  return wrapper;
}

//-----------------------------------------------------------------------------

class DelegateComponent : Component
{
  this(void delegate(TextOutputStream) d_) { d = d_; }
  
  protected void delegate(TextOutputStream) d;

  override void copy(TextOutputStream output)
  {
    d(output);
  }
}

//-----------------------------------------------------------------------------

class InputRangeComponent(R) : Component if (isInputRange!R && (is(ElementType!(R) == dchar) || isSomeString(ElementType!R)))
{
  R r;

  this(R _r) { r = r; }
  
  override void copy(TextOutputStream output)
  {
    r.copy(output);
  }
}

//-----------------------------------------------------------------------------

template TemplateOutput(string S)
{
  enum TemplateOutput = embedD(import(S),"output.print");
}

mixin template TemplateCopy(string S)
{
  override void copy(TextOutputStream output)
  {
    mixin(TemplateOutput!S);
  }
}

mixin template TemplateComponent(string S)
{
  class TC : Component
  {
    mixin TemplateCopy!S;
  }
}

//-----------------------------------------------------------------------------

class FileComponent(S = string) : Component
{
  import std.file;
  this(string _filepath) { filepath = _filepath; }
  
  override void copy(TextOutputStream output)
  {
    if (exists(filepath))
    {
      readText!S(filepath).copy(output);
    }
  }

  private:
    string filepath;
}

//-----------------------------------------------------------------------------


unittest
{
  import std.stdio;
  void pp(TextOutputStream o) { o.print("--phbf--"); }

  auto buf = appender!(char[])();
  auto bos = new TextOutputStream(output_range_stream(buf));

  auto target = new Composite();
  target.add("abc").add("xyz").add(new TextComponent("123"));

  target.add(new DelegateComponent(&pp));
  target.copy(bos);
  assert(buf.data == "abcxyz123--phbf--");
  buf.clear();

  auto wrapper = new Composite();
  wrapper.add("start!").wrap(target).add("!end");
  target.copy(bos);
  writeln(buf.data);
  assert(buf.data == "start!abcxyz123--phbf--!end");
  

/*
  import std.stdio;

  void pp(TextOutputStream o) { o.print("--phbf--"); }
  auto buf = appender!string();
  auto bos = new TextOutputStream(output_range_stream(buf));

  auto page = new Composite();
  page.add("abc").add("xyz").add(new TextComponent("123"));
  page.add(new DelegateComponent(&pp));
  page.add(new FileComponent("testfile.txt"));
  page.copy(bos);
  writeln(buf.data);
  assert(buf.data == "abcxyz123--phbf--qwerty");
*/
}
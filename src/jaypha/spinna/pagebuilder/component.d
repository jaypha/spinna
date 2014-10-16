//Written in the D programming language
/*
 * Basic Components for building output content.
 *
 * Copyright 2013 Jaypha
 *
 * Distributed under the Boost Software License, Version 1.0.
 * (See http://www.boost.org/LICENSE_1_0.txt)
 *
 * Authors: Jason den Dulk
 */

module jaypha.spinna.pagebuilder.component;

public import jaypha.types;
public import jaypha.io.output_stream;
import jaypha.embed;

public import jaypha.html.entity;
import std.algorithm;
import std.array;
import std.traits;

//-----------------------------------------------------------------------------

interface Component
{
  void copy(TextOutputStream output);
}


//-----------------------------------------------------------------------------

class TextComponent(S = string) : Component if (isSomeString!S)
{
  S text;
  
  this(S _text = null) { text = _text; }
  
  override void copy(TextOutputStream output)
  {
    output.print(text);
  }
}

//-----------------------------------------------------------------------------

class Composite : Component
{
  Composite put(string t) { content.put(new TextComponent!string(t)); return this; }
  Composite put(wstring t) { content.put(new TextComponent!wstring(t)); return this; }
  Composite put(dstring t) { content.put(new TextComponent!dstring(t)); return this; }
  Composite put(Component o) { content.put(o); return this; }

  alias put add;

  @property ulong length() { return content.data.length; }

  override void copy(TextOutputStream output)
  {
    foreach (i; content.data)
      i.copy(output);
  }

  private Appender!(Component[]) content;
}

//-----------------------------------------------------------------------------

Composite transfer(Composite source, Composite target)
{
  target.content.put(source.content.data);
  source.content.clear();
  assert(source.content.data.length == 0);
  return source;
}

Composite wrap(Composite wrapper, Composite target)
{
  target.transfer(wrapper).add(wrapper);
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

template TemplateOutput(string S, string fn = "print")
{
  enum TemplateOutput = embedD(import(S),fn);
}

mixin template TemplateCopy(string S)
{
  override void copy(TextOutputStream output)
  {
    with (output)
    {
      mixin(TemplateOutput!(S,"print"));
    }
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

  auto buf = appender!string();
  auto bos = textOutputStream(buf);

  auto target = new Composite();
  target.add("abc").add("xyz").add(new TextComponent("123"));

  target.add(new DelegateComponent(&pp));
  target.copy(bos);
  assert(buf.data == "abcxyz123--phbf--");

  buf = appender!string();
  bos = textOutputStream(buf);

  auto wrapper = new Composite();
  wrapper.add("start!").wrap(target).add("!end");
  target.copy(bos);
  //bos.print(target);
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

module jaypha.spinna.pagebuilder.htmlelement;

public import jaypha.spinna.pagebuilder.component;
import jaypha.html.entity;

import jaypha.types;
import jaypha.algorithm;

import std.algorithm;
import std.array;

import std.stdio;

/**
 * These elements are allowed to be printed using the empty tag shorthand.
 *
 * TODO - Need to find the full list of elements.
 */

class HtmlElement : Composite
{
  static immutable string[] empty_tags = ["area", "base", "basefont", "br", "col", "frame", "hr", "img", "input", "isindex", "link", "meta", "param" ];

  @property
  {
    string id() { return ("id" in attributes)?attributes["id"]:null; }
    void id(string s) { attributes["id"] = s; }
  }

  strstr   attributes;
  string[] css_classes;
  strstr   css_styles;

  string tag_name;

  this(string _tag_name = "div")        { tag_name = _tag_name; }

  @property
  {
    Component content()       { return _c; }
    void content(Component o) { _cl(); add(o); }
    void content(string t)    { _cl(); add(t); }
  }

  void add_class(string class_name)
  {
    if (find(css_classes,class_name).empty)
      css_classes ~= class_name;
  }

  void remove_class(string class_name)
  {
    uint i;
    for (; i<css_classes.length; ++i)
      if (css_classes[i] == class_name)
      {
        css_classes = remove(css_classes,i);
        return;
      }
  }

  override void copy(TextOutputStream output)
  {
    assert(!("style" in attributes));
    assert(!("class" in attributes));

    output.print("<",tag_name);
    if (css_classes.length) output.print(" class='",encode_special(css_classes.join(" ")),"'");
    if (css_styles.length)
    {
      output.print
      (
        " style='",
        encode_special
        (
          css_styles.meld!
          (
            (a,b) => (a ~":"~b)
          ).join(";")
        ),
        "'"
      );
    }
      
    foreach (name, value; attributes)
      output.print(" ",name,"='",encode_special(value),"'");
    
    if (empty_tag)
      output.print("/>");
    else
    {
      output.print(">");
      super.copy(output);
      output.print("</",tag_name,">");
    }
  }
  
  @property bool empty_tag()
  {
    return (length == 0 && !find(empty_tags,tag_name).empty);
  }

  //---------------------------------------------------------------------------
  
}

//-----------------------------------------------------------------------------

unittest
{
  import std.stdio;
  import std.range;

  auto buf = appender!(char[])();
  auto bos = new TextOutputStream(output_range_stream(buf));

  auto page = new HtmlElement("br");
  page.copy(bos);
  assert(buf.data == "<br/>");
  buf.clear();
  
  page = new HtmlElement();
  page.copy(bos);
  assert(buf.data == "<div></div>");
  buf.clear();

  page.tag_name = "img";
  page.attributes["src"] = "pig.gif";
  page.copy(bos);
  assert(buf.data == "<img src='pig.gif'/>");
  buf.clear();
  page.add_class("top");
  page.add_class("bottom");
  page.css_styles["position"] = "rela&tive";
  page.css_styles["padding"] = "5px";
  page.content = "hello";
  page.copy(bos);
  assert
  (
    buf.data == "<img class='top bottom' style='position:rela&amp;tive;padding:5px' src='pig.gif'>hello</img>" ||
    buf.data == "<img class='top bottom' style='padding:5px;position:rela&amp;tive' src='pig.gif'>hello</img>"
  );

  buf.clear();
  page = new HtmlElement();
  auto inner = new HtmlElement("p");
  inner.content = "hello";
  page.content = inner;
  page.copy(bos);
  assert(buf.data == "<div><p>hello</p></div>");
 
  buf.clear();
  page = new HtmlElement();
  page.add("abc");
  page.add("def");
  page.add(inner);
  page.copy(bos);
  assert(buf.data == "<div>abcdef<p>hello</p></div>");
}

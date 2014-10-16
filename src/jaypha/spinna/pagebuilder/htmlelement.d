/*
 * Base class for HTML elements.
 *
 * Copyright (C) 2014, Jaypha
 *
 * Distributed under the Boost Software License, Version 1.0.
 * (See http://www.boost.org/LICENSE_1_0.txt)
 *
 * Authors: Jason den Dulk
 *
 * Written in the D language.
 */

module jaypha.spinna.pagebuilder.htmlelement;

public import jaypha.spinna.pagebuilder.component;
import jaypha.html.entity;

import jaypha.types;
import jaypha.algorithm;

import std.algorithm;
import std.array;

import std.stdio;

class HtmlElement : Composite
{
  // These elements are allowed to be printed using the empty tag shorthand.

  static immutable string[] emptyTags = ["area", "base", "basefont", "br", "col", "frame", "hr", "img", "input", "isindex", "link", "meta", "param" ];

  @property
  {
    string id() { return ("id" in attributes)?attributes["id"]:null; }
    void id(string s) { attributes["id"] = s; }
  }

  strstr   attributes;
  string[] cssClasses;
  strstr   cssStyles;

  string tagName;

  //---------------------------------------------------------------------------

  this(string _tagName = "div")        { tagName = _tagName; }

  //---------------------------------------------------------------------------

  HtmlElement addClass(string className)
  {
    if (canFind(cssClasses,className))
      cssClasses ~= className;
    return this;
  }

  //---------------------------------------------------------------------------

  HtmlElement removeClass(string className)
  {
    uint i;
    for (; i<css_classes.length; ++i)
      if (cssClasses[i] == className)
      {
        cssClasses = remove(cssClasses,i);
        return this;
      }
    return this;
  }

  //---------------------------------------------------------------------------

  override void copy(TextOutputStream output)
  {
    assert(!("style" in attributes));
    assert(!("class" in attributes));

    output.print("<",tagName);
    if (cssClasses.length) output.print(" class='",encodeSpecial(cssClasses.join(" ")),"'");
    if (cssStyles.length)
    {
      output.print
      (
        " style='",
        encodeSpecial
        (
          cssStyles.meld!
          (
            (a,b) => (a ~":"~b)
          ).join(";")
        ),
        "'"
      );
    }
      
    foreach (name, value; attributes)
      output.print(" ",name,"='",encodeSpecial(value),"'");
    
    if (emptyTag)
      output.print("/>");
    else
    {
      output.print(">");
      super.copy(output);
      output.print("</",tagName,">");
    }
  }

  //---------------------------------------------------------------------------
  
  @property bool emptyTag()
  {
    return (length == 0 && !canFind(emptyTags,tagName));
  }

  //---------------------------------------------------------------------------
  
}

//-----------------------------------------------------------------------------

unittest
{
  import std.stdio;
  import std.range;

  auto buf = appender!(char[])();
  auto bos = textOutputStream(buf);

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
  page.add("hello");
  page.copy(bos);
  assert
  (
    buf.data == "<img class='top bottom' style='position:rela&amp;tive;padding:5px' src='pig.gif'>hello</img>" ||
    buf.data == "<img class='top bottom' style='padding:5px;position:rela&amp;tive' src='pig.gif'>hello</img>"
  );

  auto inner = new HtmlElement("p");
  inner.add("hello");

  buf.clear();
  page = new HtmlElement();
  page.add("abc");
  page.add("def");
  page.add(inner);
  page.copy(bos);
  assert(buf.data == "<div>abcdef<p>hello</p></div>");
}

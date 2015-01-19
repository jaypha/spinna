//Written in the D programming language
/*
 * Wide button with extra decorations.
 *
 * Copyright (C) 2014 Jaypha.
 *
 * Distributed under the Boost Software License, Version 1.0.
 * (See http://www.boost.org/LICENSE_1_0.txt)
 *
 * Authors: Jason den Dulk
 */

module jaypha.spinna.pagebuilder.widgets.wide_button;

import jaypha.spinna.pagebuilder.htmlelement;

import jaypha.rnd;

import config.general;

import std.array;
import std.conv;

import jaypha.html.helpers;

/*
 * Wide buttons have 3 parts. left, right and center. The center is the main
 * content, left and right are decorators.
 */

class WideButton : HtmlElement
{
  HtmlElement left;
  HtmlElement right;

  string link;
  string script;
  
  bool enabled = true;;
  

  this(string _id = null)
  {
    super();
    addClass("boxed");
    addClass("wide-btn");

    if (_id.empty)
      id = rndId(10);
    else
      id = _id;
  }

  override void copy(TextOutputStream output)
  {
    auto span = new HtmlElement("span");
    this.transfer(span);

    HtmlElement inner;
    if (!link.empty)
    {
      inner = new HtmlElement("a");
      inner.attributes["href"] = link;
    }
    else
    {
      if (script.empty)
        enabled = false;
      inner = new HtmlElement("span");
      inner.attributes["onclick"] = script;
    }
    inner.addClass("inner");

    span.addClass("wide-button-content");
    if (left !is null)
    {
      inner.put(left);
      left.addClass("wb-left");
    }
    if (right !is null)
    {
      inner.put(right);
      right.addClass("wb-right");
    }
    inner.put(span);
    this.put(inner);

    if (left !is null || right !is null)
      this.put("<div style='clear:both'></div>");

    inner.put("<span class='overlay'></span>");

    super.copy(output);

    if (enabled)
      output.print(javascript("$(function(){ $('#"~id~"').enableButton()});"));
    else
      output.print(javascript("$(function(){ $('#"~id~"').disableButton()});"));
  }
}

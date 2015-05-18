//Written in the D programming language
/*
 * Buttons that use Icon class.
 *
 * Copyright (C) 2014 Jaypha.
 *
 * Distributed under the Boost Software License, Version 1.0.
 * (See http://www.boost.org/LICENSE_1_0.txt)
 *
 * Authors: Jason den Dulk
 */

module jaypha.spinna.pagebuilder.widgets.iconbutton;

public import jaypha.spinna.pagebuilder.htmlelement;

public import jaypha.spinna.pagebuilder.widgets.icon;

import jaypha.rnd;

import config.general;

import std.array;
import std.conv;

import jaypha.html.helpers;

class IconButton : HtmlElement
{
  string label;
  string link;
  string script;

  Icon icon;
  bool enabled = true;;

  this(Icon _icon, string _label, string _link = null, string _id = null)
  {
    super();
    addClass("icon-btn");
  
    icon = _icon;
    label = _label;
    link = _link;
    
    if (_id.empty)
      id = rndId(10);
    else
      id = _id;
  }

  override void copy(TextOutputStream output)
  {
    assert(icon !is null);

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

    addClass("icon"~to!string(icon.size));
    inner.addClass("inner");
    inner.put(icon);
    inner.put(label);
    put(inner);
    super.copy(output);

    if (enabled)
      output.print(javascript("$(function(){ $('#"~id~"').enableButton()});"));
    else
      output.print(javascript("$(function(){ $('#"~id~"').disableButton()});"));
  }
}

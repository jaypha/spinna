//Written in the D programming language
/*
 * Tabbed panels.
 *
 * Copyright (C) 2014 Jaypha.
 *
 * Distributed under the Boost Software License, Version 1.0.
 * (See http://www.boost.org/LICENSE_1_0.txt)
 *
 * Authors: Jason den Dulk
 */

module jaypha.spinna.pagebuilder.widgets.tabbed;

public import jaypha.spinna.pagebuilder.htmlelement;

import jaypha.html.helpers;


import std.conv;
import std.algorithm;
import std.array;

class Tabbed : Component
{
  TabList tabs;
  Composite panels;
  string prefix;
  string[] ids;

  class TabList : HtmlElement
  {
    string[] labels;

    this()
    {
      super("ul");
      addClass("tab-list");
      addClass(prefix);
    }

    override void copy(TextOutputStream output)
    {
      foreach (i,l; labels)
        add("<li><a href='#"~ids[i]~"'>"~l~"</a></li>");
      super.copy(output);
      output.print("<div class='tab-list-base' style='clear:left'></div>");
    }
  }
  
  this(string p) { prefix = p; tabs = new TabList(); panels = new Composite(); }

  HtmlElement addPanel(string label, Component pane)
  {
    auto p = addPanel(label);
    p.add(pane);
    return p;
  }

  HtmlElement addPanel(string label)
  {
    auto p = new HtmlElement();
    p.addClass("tab-panel");
    p.addClass(prefix);
    auto s = prefix~"-"~to!string(ids.length);
    p.id = s;
    ids ~= s;
    tabs.labels ~= label;
    panels.add(p);
    return p;
  }

  override void copy(TextOutputStream output)
  {
    tabs.copy(output);
    panels.copy(output);
    output.print
    (
      startUpJavascript
      (
        "activatables('"~
        prefix~
        "', ["~
        ids.map!(a => "'"~a~"'").join(",") ~ "]);"
      )
    );
  }
}


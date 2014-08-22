/*
 * Widget to select items from a list.
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

module jaypha.spinna.pagebuilder.widgets.selector;

public import jaypha.spinna.pagebuilder.widgets.widget;
public import jaypha.spinna.pagebuilder.widgets.enumerated;

import std.array;
import std.algorithm;
import std.conv;
import jaypha.container.hash;
import jaypha.html.helpers;


class SelectorWidget(string tpl = "jaypha/spinna/pagebuilder/widgets/selector.tpl") : Widget
{
  class SelectorTpl : Component
  {
    EnumeratedOption[] options;
    string[] selected;
    string name;

    mixin TemplateCopy!tpl;
  }

  @property
  {
    override string value() { return selected.join(","); }
    override void value(string v) { selected = v.split(","); }
  }

  @property
  {
    override string name() { return attributes["name"]; }
    override void name(string v) { attributes["name"] = v; }
  }

  uint min_options = 0;
  uint max_options = 0;
  EnumeratedOption[] options;
  string[] selected;
  
  this(HtmlForm _form, string _name)
  {
    super(_form, _name,null,false,"div");
    add_class("selector-widget");

  }

  override void copy(TextOutputStream output)
  {
    auto c = new SelectorTpl();
    c.options = options;
    c.selected = selected;
    c.name = name;
    
    add(c);

    //form.doc.page_head.add_script("add_selector_widget('"~name~"','"~label~"','"~form.id~"',"~to!string(min_options)~","~to!string(max_options)~");", true);
    super.copy(output);
  }
}

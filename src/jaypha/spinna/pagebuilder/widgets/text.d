/*
 * Widget for multi line strings
 *
 * Copyright 2013 Jaypha.
 *
 * Distributed under the Boost Software License, Version 1.0.
 * (See http://www.boost.org/LICENSE_1_0.txt)
 *
 * Authors: Jason den Dulk
 *
 * Written in the D language.
 */

module jaypha.spinna.pagebuilder.widgets.text;

public import jaypha.spinna.pagebuilder.widgets.widget;

//import std.array;
import std.conv;

//----------------------------------------------------------------------------

class TextWidget : Widget
{
  TextComponent _value;

  @property
  {
    override string value() { return _value.text; }
    override void value(string v) { _value.text = v; }
  }

  @property
  {
    override string name() { return attributes["name"]; }
    override void name(string v) { attributes["name"] = v; }
  }

  this(HtmlForm _form, string _name)
  {
    super(_form, _name,"textarea");
    add_class("text-widget");
    _value = new TextComponent();
  }

  override void copy(TextOutputStream output)
  {
    if (max_length != 0) attributes["max_length"] = to!string(max_length);
    form.doc.page_head.add_script("add_string_widget('"~name~"','"~label~"','"~form.id~"',"~(required?"true":"false")~",0,"~to!string(max_length)~",null);");
    content = _value;
    super.copy(output);
  }

  ulong max_length = 0;
}

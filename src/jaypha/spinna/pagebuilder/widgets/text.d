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
import jaypha.html.helpers;

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

  this
  (
    HtmlForm _form,
    string _name,
    string _label,
    bool _required,
    ulong _min = 0,
    ulong _max = 0
  )
  {
    _value = new TextComponent();
    super(_form, _name, _label, _required, "textarea");
    add_class("text-widget");
    min_length = _min;
    max_length = _max;
  }

  override void copy(TextOutputStream output)
  {
    if (max_length != 0) attributes["maxlength"] = to!string(max_length);
    add(_value);
    super.copy(output);
    output.print(javascript("new StringWidget($('#"~id~"'), { minLen: "~to!string(min_length)~", maxLen: "~to!string(max_length)~", required: "~to!string(required)~" });"));
  }

  ulong min_length = 0;
  ulong max_length = 0;

  string regex;
}

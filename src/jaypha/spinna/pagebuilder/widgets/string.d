/*
 * Widget for single line strings
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

module jaypha.spinna.pagebuilder.widgets.string;

public import jaypha.spinna.pagebuilder.widgets.widget;

//import std.array;
import std.conv;
import jaypha.html.helpers;

//----------------------------------------------------------------------------

class StringWidget : Widget
{
  @property
  {
    override string value() { return ("value" in attributes)?attributes["value"]:null; }
    override void value(string v) { attributes["value"] = v; }
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
    bool _required = false,
    ulong _min = 0,
    ulong _max = 0,
  )
  {
    super(_form, _name, _label, _required, "input");
    add_class("string-widget");
    attributes["type"] = "text";
    min_length = _min;
    max_length = _max;
  }

  override void copy(TextOutputStream output)
  {
    if (max_length != 0) attributes["maxlength"] = to!string(max_length);
    if (is_password) attributes["type"] = "password";
    super.copy(output);
    output.print(javascript("new StringWidget($('#"~id~"'), { minLen: "~to!string(min_length)~", maxLen: "~to!string(max_length)~", required: "~to!string(required)~" });"));
  }

  ulong min_length = 0;
  ulong max_length = 0;
  bool is_password = false;

  string regex;
}

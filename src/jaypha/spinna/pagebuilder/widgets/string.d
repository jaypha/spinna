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
    bool _required,
    ulong _min = 0,
    ulong _max = 0,
  )
  {
    super(_form, _name,"input");
    add_class("string-widget");
    label = _label;
    required = _required;
    attributes["type"] = "text";
    min_length = _min;
    max_length = _max;
  }

  override void copy(TextOutputStream output)
  {
    if (max_length != 0) attributes["maxlength"] = to!string(max_length);
    if (is_password) attributes["type"] = "password";
    form.doc.page_head.add_script
    (
      "add_string_widget('"~name~"','"~label~"','"~form.id~"',"~(required?"true":"false")~","~to!string(min_length)~","~to!string(max_length)~","~((regex is null || regex.length == 0)?"null":"'"~regex~"'")~");",
      true
    );
    super.copy(output);
  }

  ulong min_length = 0;
  ulong max_length = 0;
  bool is_password = false;

  string regex;
}

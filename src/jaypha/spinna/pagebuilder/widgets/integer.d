/*
 * Widget for integers
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

module jaypha.spinna.pagebuilder.widgets.integer;

public import jaypha.spinna.pagebuilder.widgets.widget;

import std.conv;
import jaypha.html.helpers;

//----------------------------------------------------------------------------

class IntegerWidget : Widget
{
  @property
  {
    override string value() { return ("value" in attributes)?attributes["value"]:null; }
    override void value(string v) { to!long(v); attributes["value"] = v; }

    void value(long v) { attributes["value"] = to!string(v); }
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
    long _min = long.min,
    long _max = long.max
  )
  {
    super(_form, _name, _label, _required, "input");
    add_class("integer-widget");
    min_value = _min;
    max_value = _max;
  }

  override void copy(TextOutputStream output)
  {
    super.copy(output);
    output.print(javascript("new IntegerWidget($('#"~id~"'), {label: '"~label~"', required: "~to!string(required)~", max:"~to!string(max_value)~",min:"~to!string(min_value)~",spinner:"~to!string(add_spinner)~"});"));
    //output.print("<script type='text/javascript'>$(function(){$('#"~id~"').IntegerWidget({max:"~to!string(max_value)~",min:"~to!string(min_value)~",spinna:"~(add_spinner?"true":"false")~"})});</script>");
  }

  bool add_spinner = false;
  long min_value;
  long max_value;
}

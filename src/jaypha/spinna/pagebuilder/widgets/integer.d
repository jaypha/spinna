//Written in the D programming language
/*
 * Widget for integers
 *
 * Copyright 2013 Jaypha.
 *
 * Distributed under the Boost Software License, Version 1.0.
 * (See http://www.boost.org/LICENSE_1_0.txt)
 *
 * Authors: Jason den Dulk
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
    addClass("integer-widget");
    minValue = _min;
    maxValue = _max;
  }

  override void copy(TextOutputStream output)
  {
    super.copy(output);
    output.print(javascript("new IntegerWidget($('#"~id~"'), {label: '"~label~"', required: "~to!string(required)~", max:"~to!string(maxValue)~",min:"~to!string(minValue)~",spinner:"~to!string(addSpinner)~"});"));
  }

  bool addSpinner = false;
  long minValue;
  long maxValue;
}

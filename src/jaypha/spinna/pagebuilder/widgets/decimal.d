//Written in the D programming language
/*
 * Widget for decimal (fixed point) values.
 *
 * Copyright 2013 Jaypha
 *
 * Distributed under the Boost Software License, Version 1.0.
 * (See http://www.boost.org/LICENSE_1_0.txt)
 *
 * Authors: Jason den Dulk
 */

module jaypha.spinna.pagebuilder.widgets.decimal;

public import jaypha.spinna.pagebuilder.widgets.widget;
public import jaypha.decimal;

import std.conv;
import jaypha.html.helpers;

import jaypha.container.hash;

class DecimalWidget(uint scale = 2) : Widget
{
  alias decimal!scale D;

  @property
  {
    override string value() { return ("value" in attributes)?attributes["value"]:null; }
    override void value(string v) { attributes["value"] = v; }

    void value(D v) { attributes["value"] = v.toString(); }

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
    D _min = D.min,
    D _max = D.max
  )
  {
    super(_form, _name, _label, _required, "input");
    addClass("decimal-widget");
    minValue = _min;
    maxValue = _max;
  }

  override void copy(TextOutputStream output)
  {
    super.copy(output);
    output.print(javascript("new DecimalWidget($('#"~id~"'),{ label: '"~label~"', scale: "~to!string(scale)~", required:"~(required?"true":"false")~",min: "~minValue.toString()~",max:"~maxValue.toString()~"});"));
  }

  D minValue;
  D maxValue;
}

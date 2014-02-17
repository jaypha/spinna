/*
 * Widget for decimal (fixed point) values.
 *
 * Copyright 2013 Jaypha
 *
 * Distributed under the Boost Software License, Version 1.0.
 * (See http://www.boost.org/LICENSE_1_0.txt)
 *
 * Authors: Jason den Dulk
 *
 * Written in the D programming language.
 */

module jaypha.spinna.pagebuilder.widgets.decimal;

public import jaypha.spinna.pagebuilder.widgets.widget;
public import jaypha.decimal;

import std.conv;

import jaypha.container.hash;

class DecimalWidget(uint scale) : Widget
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
    super(_form, _name,"input");
    add_class("decimal-widget");
    label = _label;
    required = _required;
    min_value = _min;
    max_value = _max;
  }

  override void copy(TextOutputStream output)
  {
    form.doc.page_head.add_script
    (
      "add_decimal_widget('"~name~"','"~label~"','"~form.id~"',"~(required?"true":"false")~","~min_value.toString()~","~max_value.toString()~");",
      true
    );
    super.copy(output);
  }

  D min_value;
  D max_value;
}

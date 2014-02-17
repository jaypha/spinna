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
    super(_form, _name,"input");
    add_class("integer-widget");
    label = _label;
    required = _required;
    min_value = _min;
    max_value = _max;
  }

  override void copy(TextOutputStream output)
  {
    //form.doc.page_head.add_script
    //(
    //  "add_integer_widget('"~name~"','"~label~"','"~form.id~"',"~(required?"true":"false")~","~(min_value == long.min?"null":to!string(min_value))~","~(max_value == long.max?"null":to!string(max_value))~","~(add_spinner?"true":"false")~");",
    //  true
    //);
    if (add_spinner)
      output.print("<span class='integer-widget-wrapper' id='",id,"-wrapper'>");
    super.copy(output);
    if (add_spinner)
      output.print("<a class='spinner-up'>&#9650;</a><a class='spinner-down'>&#9660;</a></span>");
    output.print("<script type='text/javascript'>$(function(){add_integer_widget('"~name~"','"~label~"',"~(form is null?"null":"'"~form.id~"'")~",'"~id~"',"~(required?"true":"false")~","~(min_value == long.min?"null":to!string(min_value))~","~(max_value == long.max?"null":to!string(max_value))~","~(add_spinner?"true":"false")~");});</script>");
  }

  bool add_spinner = false;
  long min_value;
  long max_value;
}

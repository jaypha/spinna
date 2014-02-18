/*
 * Widget for date values
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

module jaypha.spinna.pagebuilder.widgets.date;

public import jaypha.spinna.pagebuilder.widgets.widget;

//import std.array;
import std.conv;

//----------------------------------------------------------------------------

class DateWidget : Widget
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
    attributes["type"] = (name == "password")? "password" : "text";
    min_length = _min;
    max_length = _max;
  }

  override void copy(TextOutputStream output)
  {
    string x = "<input name='"~name~"' style='display:none;' id='"~id~"'/>";
    name = null;
    id=id~"-display";
    form.doc.page_head.add_script
    (
      "add_date_widget('"~name~"','"~label~"','"~form.id~"',"~(required?"true":"false")~");",
      true
    );
    super.copy(output);
    ouput.print(x);
  }

  ulong min_length = 0;
  ulong max_length = 0;

  string regex;
}

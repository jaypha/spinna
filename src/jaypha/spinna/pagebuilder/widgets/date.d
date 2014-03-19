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
    override void value(string v) { attributes["value"] = v; /* TODO validate v */ }
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
  )
  {
    super(_form, _name,"input");
    add_class("date-widget");
    label = _label;
    required = _required;
  }

  override void copy(TextOutputStream output)
  {
    string x = "<input name='"~name~"' style='display:none;' id='"~id~"'/>";
    form.doc.page_head.add_script
    (
      "add_date_widget('"~name~"','"~label~"','"~form.id~"',"~(required?"true":"false")~");",
      true
    );
    name = null;
    id=id~"-display";
    attributes["readonly"] = "readonly";
    super.copy(output);
    output.print(x);
  }
}

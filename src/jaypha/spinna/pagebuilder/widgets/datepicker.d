//Written in the D programming language
/*
 * Widget for date values
 *
 * Copyright 2013 Jaypha.
 *
 * Distributed under the Boost Software License, Version 1.0.
 * (See http://www.boost.org/LICENSE_1_0.txt)
 *
 * Authors: Jason den Dulk
 */

module jaypha.spinna.pagebuilder.widgets.datepicker;

public import jaypha.spinna.pagebuilder.widgets.widget;

import std.conv;
import jaypha.html.helpers;

//----------------------------------------------------------------------------

class DatePickerWidget : Widget
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
    bool _required
  )
  {
    super(_form, _name, _label, _required, "input");
    addClass("date-widget");
  }

  override void copy(TextOutputStream output)
  {
    output.print("<input type='hidden' name='"~name~"' id='"~id~"-ret'/>");
    auto x = name;
    name = null;
    attributes["readonly"] = "readonly";
    super.copy(output);
    name = x;
    output.print(javascript("new DatePickerWidget($('#"~id~"'), $('#"~id~"-ret'), {label: '"~label~"', required:"~(required?"true":"false")~"});"));
  }
}

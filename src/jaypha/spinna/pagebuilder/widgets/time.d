//Written in the D programming language
/*
 * Widget for time values
 *
 * Copyright 2013 Jaypha.
 *
 * Distributed under the Boost Software License, Version 1.0.
 * (See http://www.boost.org/LICENSE_1_0.txt)
 *
 * Authors: Jason den Dulk
 */

module jaypha.spinna.pagebuilder.widgets.time;

public import jaypha.spinna.pagebuilder.widgets.widget;

import std.conv;
import jaypha.html.helpers;

//----------------------------------------------------------------------------

class TimeWidget : Widget
{
  @property
  {
    override string value() { return _value; }
    override void value(string v) { _value = v; /* TODO validate v */ }
  }

  @property
  {
    override string name() { return _name; }
    override void name(string v) { _name = v; }
  }

  this
  (
    HtmlForm _form,
    string _name,
    string _label,
    bool _required
  )
  {
    super(_form, _name, _label, _required, "span");
    addClass("time-widget");
  }

  override void copy(TextOutputStream output)
  {
    output.print("<input type='hidden' name='"~name~"' id='"~id~"-ret'/>");
    super.copy(output);
    output.print(javascript("new TimePickerWidget($('#"~id~"'), $('#"~id~"-ret'), {label: '"~label~"', required:"~(required?"true":"false")~"});"));
  }

  private:
    string _name,  _value;

}

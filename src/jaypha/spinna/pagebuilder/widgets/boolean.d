/*
 * Widget for boolean values.
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

/*
 * Boolean widgets are strict true/false widgets, use an enumerated widget if
 * you want to have no initial setting, or a "don't care" option.
 */

module jaypha.spinna.pagebuilder.widgets.boolean;

public import jaypha.spinna.pagebuilder.widgets.widget;

import jaypha.html.helpers;
import std.conv;

class BooleanWidget : Widget
{
  @property
  {
    override string value() { return _v?"1":"0"; }
    override void value(string v)
    {
      if (v is null || v == "" || v == "0" || v == "f" || v == "false") _v = false;
      else _v = true;
    }
  }

  @property
  {
    override string name() { return _n; }
    override void name(string v) { _n = v; }
  }

  void set() { _v = true; }
  void clear() { _v = false; }

  this
  (
    HtmlForm _form,
    string _name,
    string _label,
    bool _required = false
  )
  {
    super(_form, _name, _label, _required);
    add_class("boolean-widget");

    add(new DelegateComponent(&display));
  }

  override void copy(TextOutputStream output)
  {
    super.copy(output);
    output.print(javascript("new BooleanWidget($('#"~id~"'), {label: '"~label~"', required: "~to!string(required)~"});"));
  }

  void display(TextOutputStream output)
  {
    output.print("<span class='true-setting'>Yes</span><span class='false-setting'>No</span><input type='hidden' name='"~_n~"' value='"~value~"'/>");
  }

  private:
    bool _v;
    string _n;
}

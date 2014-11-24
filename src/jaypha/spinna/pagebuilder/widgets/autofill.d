//Written in the D programming language
/*
 * Auto fill widget.
 *
 * Copyright (C) 2014, Jaypha
 *
 * Distributed under the Boost Software License, Version 1.0.
 * (See http://www.boost.org/LICENSE_1_0.txt)
 *
 * Authors: Jason den Dulk
 */

module jaypha.spinna.pagebuilder.widgets.autofill;

public import jaypha.spinna.pagebuilder.widgets.widget;
public import jaypha.spinna.pagebuilder.widgets.enumerated;

import std.array;
import jaypha.html.helpers;

class AutofillWidget : Widget
{
  @property
  {
    override string value() { return _value; }
    override void value(string v) { _value = v; }
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
    EnumeratedOption[] _options
  )
  {
    super(_form, _name, _label, _required, "input");
    attributes["type"] = "text";
    options = _options;
    addClass("dropselect-widget");
  }

  override void copy(TextOutputStream output)
  {
    auto x = name;
    name = null;
    super.copy(output);
    name = x;
    output.print("<input type='hidden' name='"~name~"' id='"~id~"-ret'/>");
    auto option_list = appender!(string[])();
    foreach (option; options)
      option_list.put("[ '"~option.value~"', '"~option.label~"' ]");
    output.print(javascript("new AutofillWidget($('#"~id~"'), { label: '"~label~"', required:"~(required?"true":"false")~", list: ["~option_list.data.join(",")~"] });"));
  }

  EnumeratedOption[] options;
  private:
    string  _value;
}

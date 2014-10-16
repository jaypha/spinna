//Written in the D programming language
/*
 * Radio group widget.
 *
 * Copyright 2013 Jaypha
 *
 * Distributed under the Boost Software License, Version 1.0.
 * (See http://www.boost.org/LICENSE_1_0.txt)
 *
 * Authors: Jason den Dulk
 */

module jaypha.spinna.pagebuilder.widgets.radiogroup;

public import jaypha.spinna.pagebuilder.widgets.widget;
public import jaypha.spinna.pagebuilder.widgets.enumerated;

import std.array;
import std.conv;
import jaypha.html.helpers;

class RadioGroupWidget: Widget
{
  @property
  {
    override string value() { return _value; }
    override void value(string v) { _value = v; }
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
    bool _required,
    EnumeratedOption[] _options
  )
  {
    super(_form, _name, _label, _required, "span");
    options = _options;
    addClass("enum-widget");
    addClass("radiogroup-widget");
  }

  override void copy(TextOutputStream output)
  {
    auto c = appender!string();

    foreach (o;options)
    {
      auto option_id = id~"-"~o.value;
      c.put("<label for='");
      c.put(option_id);
      c.put("'>&nbsp;");
      c.put(o.label);
      c.put("</label>");
      c.put("<input type='radio' id='");
      c.put(option_id);
      c.put("' name='");
      c.put(name);
      c.put("' value='");
      c.put(o.value);
      c.put("'");
      if (_value == o.value)
        c.put(" checked='checked'");
      c.put("/>");
    }
    put(c.data);

    super.copy(output);
    output.print(javascript("new EnumGroupWidget($('#"~id~"'),'"~_name~"',{ label: '"~label~"', minSel: "~(required?"1":"0")~", maxSel: 1 });"));
  }

  @property vertical() { addClass("vertical"); removeClass("horizontal"); }
  @property horizontal() { addClass("horizontal"); removeClass("vertical"); }

  EnumeratedOption[] options;
  private:
    string _name,  _value;
}
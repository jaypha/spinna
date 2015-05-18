//Written in the D programming language
/*
 * Drop down (select) widget.
 *
 * Copyright 2013 Jaypha
 *
 * Distributed under the Boost Software License, Version 1.0.
 * (See http://www.boost.org/LICENSE_1_0.txt)
 *
 * Authors: Jason den Dulk
 */

module jaypha.spinna.pagebuilder.widgets.dropdownlist;

public import jaypha.spinna.pagebuilder.widgets.widget;
public import jaypha.spinna.pagebuilder.widgets.enumerated;

import std.array;
import jaypha.html.helpers;

class DropdownListWidget : Widget
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
    super(_form, _name, _label, _required, "select");
    options = _options;
    addClass("dropselect-widget");
  }

  override void copy(TextOutputStream output)
  {
    auto c = appender!string();

    if ((_value is null || _value == "") || !required)
      c.put("<option value=''> -- none -- </option>");

    foreach (o;options)
    {
      c.put("<option value='");
      c.put(o.value);
      if (o.value == _value)
        c.put("' selected='selected");
      c.put("'>");
      c.put(o.label);
      c.put("</option>");
    }
    put(c.data);

    super.copy(output);
    output.print(javascript("new DropdownListWidget($('#"~id~"'),{ label: '"~label~"', required: "~(required?"true":"false")~"});"));
  }

  override JSONValue toJson()
  {
    JSONValue[string] constraints = 
    [ 
      "max": JSONValue(1),
      "min": JSONValue(required?1:0)
    ];

    auto ops = appender!(JSONValue[])();
    foreach (o;options)
      ops.put(JSONValue([ "label" : JSONValue(o.label), "value": JSONValue(o.value) ]));

    JSONValue[string] retval = 
      [
        "name": JSONValue(name),
        "type": JSONValue("enum"),
        "label": JSONValue(label),
        "constraints": JSONValue(constraints),
        "options": JSONValue(ops.data)
      ];

    if (!value.empty)
      retval["default"] = JSONValue(value);

    return JSONValue(retval);
  }

  EnumeratedOption[] options;
  private:
    string  _value;
}

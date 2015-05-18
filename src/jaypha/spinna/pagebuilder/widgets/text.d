//Written in the D programming language
/*
 * Widget for multi line strings
 *
 * Copyright 2013 Jaypha.
 *
 * Distributed under the Boost Software License, Version 1.0.
 * (See http://www.boost.org/LICENSE_1_0.txt)
 *
 * Authors: Jason den Dulk
 */

module jaypha.spinna.pagebuilder.widgets.text;

public import jaypha.spinna.pagebuilder.widgets.widget;

import std.array;
import std.conv;
import jaypha.html.helpers;

//----------------------------------------------------------------------------

class TextWidget : Widget
{
  string _value;

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
    ulong _min = 0,
    ulong _max = 0
  )
  {
    super(_form, _name, _label, _required, "textarea");
    addClass("text-widget");
    minLength = _min;
    maxLength = _max;
  }

  override void copy(TextOutputStream output)
  {
    if (maxLength != 0) attributes["maxlength"] = to!string(maxLength);
    put(new DelegateComponent(&copyValue));
    super.copy(output);
    output.print(javascript("new StringWidget($('#"~id~"'), { label: '"~label~"', minLength: "~to!string(minLength)~", maxLength: "~to!string(maxLength)~", required: "~to!string(required)~" });"));
  }

  void copyValue(TextOutputStream output)
  {
    output.print(_value);
  }

  ulong minLength = 0;
  ulong maxLength = 0;

  string regex;

  override JSONValue toJson()
  {
    JSONValue[string] retval = 
    [
      "name": JSONValue(name),
      "type": JSONValue("string"),
      "label": JSONValue(label),
      "required" : JSONValue(required),
      "subtype" : JSONValue("textarea")
    ];
    if (maxLength != 0)
      retval["maxLength"] = JSONValue(maxLength);
    if (minLength != 0)
      retval["minLength"] = JSONValue(minLength);
    if (!regex.empty)
      retval["regex"] = JSONValue(regex);

    if (!value.empty)
      retval["default"] = JSONValue(value);

    return JSONValue(retval);
  }
}

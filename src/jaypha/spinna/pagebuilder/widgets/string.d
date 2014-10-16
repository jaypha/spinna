//Written in the D programming language
/*
 * Widget for single line strings
 *
 * Copyright 2013 Jaypha.
 *
 * Distributed under the Boost Software License, Version 1.0.
 * (See http://www.boost.org/LICENSE_1_0.txt)
 *
 * Authors: Jason den Dulk
 */

module jaypha.spinna.pagebuilder.widgets.string;

public import jaypha.spinna.pagebuilder.widgets.widget;

import std.array;
import std.conv;
import jaypha.html.helpers;

//----------------------------------------------------------------------------

class StringWidget : Widget
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
    super(_form, _name, _label, _required, "input");
    addClass("string-widget");
    attributes["type"] = "text";
    minLength = _min;
    maxLength = _max;
  }

  override void copy(TextOutputStream output)
  {
    if (maxLength != 0) attributes["maxlength"] = to!string(maxLength);
    if (isPassword) attributes["type"] = "password";
    super.copy(output);
    output.print(javascript("new StringWidget($('#"~id~"'), { label: '"~label~"', minLength: "~to!string(minLength)~", maxLength: "~to!string(maxLength)~", required: "~to!string(required)~" });"));
  }

  ulong minLength = 0;
  ulong maxLength = 0;
  bool isPassword = false;

  string regex;

  override JSONValue toJson()
  {
    JSONValue[string] retval = 
    [
      "name": JSONValue(name),
      "type": JSONValue("string"),
      "label": JSONValue(label),
      "required" : JSONValue(required)
    ];
    if (maxLength != 0)
      retval["maxLength"] = JSONValue(maxLength);
    if (minLength != 0)
      retval["minLength"] = JSONValue(minLength);
    if (!regex.empty)
      retval["regex"] = JSONValue(regex);
    if (isPassword)
      retval["subtype"] = JSONValue("password");
    if (!value.empty)
      retval["default"] = JSONValue(value);

    return JSONValue(retval);
  }
}

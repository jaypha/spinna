//Written in the D programming language
/*
 * Base class for form widgets
 *
 * Copyright (C) 2014, Jaypha
 *
 * Distributed under the Boost Software License, Version 1.0.
 * (See http://www.boost.org/LICENSE_1_0.txt)
 *
 * Authors: Jason den Dulk
 */
 
module jaypha.spinna.pagebuilder.widgets.widget;

public import jaypha.spinna.pagebuilder.htmlelement;
public import jaypha.spinna.pagebuilder.htmlform;

public import std.json;
import std.array;

abstract class Widget : HtmlElement
{
  bool required;
  string label;

  HtmlForm form;

  @property { string value(); void value(string); }
  @property { string name(); void name(string); }


  this
  (
    HtmlForm _form,
    string _name,
    string _label,
    bool _required,
    string _tagName = "div"
  )
  {
    super(_tagName);
    form = _form;
    name = _name;
    label = _label;
    required = _required;
    addClass("widget");

    if (_form !is null)
      id = _form.id~"-"~_name;
    else
      id = _name;
  }

  override void copy(TextOutputStream output)
  {
    if (!(form is null) && name in form.values)
      value = form.values[name];
    super.copy(output);
  }

  JSONValue toJson() { return JSONValue(null); }
}

class WidgetComponent(alias tpl = "jaypha/spinna/pagebuilder/widgets/default_widgets.tpl") : Component
{
  string id;
  Widget[] widgets;

  mixin TemplateCopy!tpl;
}

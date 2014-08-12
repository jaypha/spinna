/*
 * Select from a list using checkboxes.
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


module jaypha.spinna.pagebuilder.widgets.checkgroup;

public import jaypha.spinna.pagebuilder.widgets.widget;
public import jaypha.spinna.pagebuilder.widgets.enumerated;

import std.array;
import std.conv;
import std.algorithm;

class CheckGroupWidget: Widget
{
  @property
  {
    override string value() { return values.join(","); }
    override void value(string v) { values = v.split(","); }

    void value(string[] v) { values = v; }
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
    super(_form, _name,"div");
    label = _label;
    required = _required;
    options = _options;
    add_class("enum-widget");
    add_class("checkgroup-widget");
    add_class("vertical");
  }

  override void copy(TextOutputStream output)
  {
    // TODO this is not ideal.
    if (name in form.values)
      value = form.values[name];

    form.doc.page_head.add_script("add_checkgroup_widget('"~name~"','"~label~"','"~form.id~"',"~(required?"true":"false")~");",true);
    
    auto c = appender!string();

    foreach (o;options)
    {
      auto option_id = form.id~"-"~name~"-"~o.value;
      c.put("<label for='");
      c.put(option_id);
      c.put("'>&nbsp;");
      c.put(o.label);
      c.put("</label>");
      c.put("<input type='checkbox' id='");
      c.put(option_id);
      c.put("' name='");
      c.put(name);
      c.put("' value='");
      c.put(o.value);
      c.put("'");
      if (canFind(values,o.value))
        c.put(" checked='checked'");
      c.put("/>");
    }
    add(new TextComponent(c.data));
    super.copy(output);
  }

  EnumeratedOption[] options;

  @property vertical() { add_class("vertical"); remove_class("horizontal"); }
  @property horizontal() { add_class("horizontal"); remove_class("vertical"); }

  private:
    string _name;
    string[] values;
}
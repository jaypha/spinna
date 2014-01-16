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
    bool _required,
    bool _default = false
  )
  {
    super(_form, _name);
    add_class("boolean-widget");
    label = _label;
    required = _required;
    _v = _default;
  }

  override void copy(TextOutputStream output)
  {
    content = "<span class='true-setting'>Yes</span><span class='false-setting'>No</span><input type='hidden' name='"~_n~"' value='"~value~"'/>";
    form.doc.page_head.add_script
    (
      "add_boolean_widget('" ~_n~ "','" ~label~ "','" ~form.id~ "'," ~(required?"true":"false")~ ");",
      true
    );
    super.copy(output);
  }

  private:
    bool _v;
    string _n;
}
module jaypha.spinna.pagebuilder.widgets.dropdown_list;

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
    add_class("dropselect-widget");
  }

  override void copy(TextOutputStream output)
  {
    add(new DelegateComponent(&print_innards));
    super.copy(output);
    output.print(javascript("new DropdownListWidget($('#"~id~"'),{required: "~(required?"true":"false")~"});"));
  }

  void print_innards(TextOutputStream c)
  {
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
  }

  EnumeratedOption[] options;
  private:
    string  _value;
}

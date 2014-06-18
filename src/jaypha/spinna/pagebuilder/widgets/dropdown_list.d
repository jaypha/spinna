module jaypha.spinna.pagebuilder.widgets.dropdown_list;

public import jaypha.spinna.pagebuilder.widgets.widget;
public import jaypha.spinna.pagebuilder.widgets.enumerated;

import std.array;

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
    super(_form, _name,"select");
    label = _label;
    required = _required;
    options = _options;
    add_class("dropselect-widget");
  }

  override void copy(TextOutputStream output)
  {
    auto d = new DelegateComponent(&print_innards);
    /*
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
    add(c.data);
    */
    add(d);
    form.doc.page_head.add_script("add_dropdown_list_widget('"~name~"','"~label~"','"~form.id~"',"~(required?"true":"false")~");", true);

    super.copy(output);
  }

  void print_innards(TextOutputStream c)
  {
    //auto c = appender!string();
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

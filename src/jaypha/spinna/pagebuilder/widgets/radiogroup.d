
module jaypha.spinna.pagebuilder.widgets.radiogroup;

public import jaypha.spinna.pagebuilder.widgets.widget;
public import jaypha.spinna.pagebuilder.widgets.enumerated;

import std.array;
import std.conv;

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
    super(_form, _name,"div");
    label = _label;
    required = _required;
    options = _options;
    add_class("radiogroup-widget");
  }

  override void copy(TextOutputStream output)
  {
    // TODO this is not ideal.
    if (name in form.values)
      value = form.values[name];

    form.doc.page_head.add_script("add_radiogroup_widget('"~name~"','"~label~"','"~form.id~"',"~(required?"true":"false")~");",true);
    
    auto c = appender!string();

    foreach (o;options)
    {
      auto option_id = form.id~"-"~name~"-"~o.value;
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
      if (value == o.value)
        c.put(" checked='checked'");
      c.put("/>");
      // TODO maybe vertical.
    }
    content = new TextComponent(c.data);
    super.copy(output);
  }

  EnumeratedOption[] options;
  private:
    string _name,  _value;
}
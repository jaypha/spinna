
module jaypha.spinna.pagebuilder.widgets.text;

public import jaypha.spinna.pagebuilder.widgets.widget;

import std.array;
import std.conv;

class TextWidget : Widget
{
  TextComponent _value;;

  @property
  {
    override string value() { return _value.text; }
    override void value(string v) { _value.text = v; }
  }

  @property
  {
    override string name() { return attributes["name"]; }
    override void name(string v) { attributes["name"] = v; }
  }

  this(HtmlForm _form, string _name)
  {
    super(_form, _name,"textarea");
    add_class("text-widget");
    _value = new TextComponent();
    content = _value;
  }

  override void copy(TextOutputStream output)
  {
    if (max_length != 0) attributes["max_length"] = to!string(max_length);
    form.doc.page_head.add_script("add_string_widget('"~name~"','"~label~"','"~form.id~"',"~(required?"true":"false")~",0,"~to!string(max_length)~",null);");
    super.copy(output);
  }

  uint max_length = 0;
}

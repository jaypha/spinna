
module jaypha.spinna.pagebuilder.widgets.string_widget;

public import jaypha.spinna.pagebuilder.widgets.widget;

import std.array;
import std.conv;

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

  this(HtmlForm _form, string _name, bool is_password = false)
  {
    super(_form, _name,"input");
    attributes["type"] = is_password? "password" : "text";
    add_class("string-widget");
  }

  override void copy(TextOutputStream output)
  {
    if (max_length != 0) attributes["max_length"] = to!string(max_length);
    form.doc.page_head.add_script("add_string_widget('"~name~"','"~label~"','"~form.id~"',"~(required?"true":"false")~","~to!string(min_length)~","~to!string(max_length)~","~((regex is null || regex.length == 0)?"null":"'"~regex~"'")~");");
    super.copy(output);
  }

  uint min_length = 0;
  uint max_length = 0;

  string regex;
}

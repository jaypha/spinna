
module jaypha.spinna.pagebuilder.widgets.boolean_widget;

public import jaypha.spinna.pagebuilder.widgets.widget;

import std.array;
import std.conv;
import std.typecons;

class BooleanWidget : Widget
{
  @property
  {
    override string value() { return _v.isNull?null:(_v?"1":"0"); }
    override void value(string v)
    {
      if (v is null || v == "") _v.nullify();
      else if (v=="1" || v == "t" || v == "true" || v == "T") _v = true;
      else _v = false;
    }
  }

  @property
  {
    override string name() { return _n; }
    override void name(string v) { _n = v; }
  }

  this(HtmlForm _form, string _name, bool is_password = false)
  {
    super(_form, _name);
    add_class("boolean-widget");
  }

  override void copy(TextOutputStream output)
  {
    content = "<span class='true-setting'>Yes</span><span class='false-setting'>No</span><input type='hidden' name='"~_n~"'"~(_v.isNull?"":" value='"~value~"'")~"/>";
    form.doc.page_head.add_script
    (
      "add_boolean_widget('" ~_n~ "','" ~label~ "','" ~form.id~ "'," ~(required?"true":"false")~ ");",
      true
    );
    //form.doc.page_head.add_script("set_boolean('"~form.id~"','"~_n~"')",true);
    super.copy(output);
  }

  private:
    Nullable!bool _v;
    string _n;
}

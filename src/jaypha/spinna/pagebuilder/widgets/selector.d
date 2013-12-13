
module jaypha.spinna.pagebuilder.widgets.selector;

public import jaypha.spinna.pagebuilder.widgets.widget;

import std.array;
import std.algorithm;
import std.conv;
import jaypha.container.hash;


struct SelectorOption
{
  string label;
  string value;
}

class SelectorWidget(alias Tpl = "jaypha/spinna/pagebuilder/widgets/selector.tpl") : Widget
{
  class SelectorTpl : Component
  {
    SelectorOption[] options;
    string[] selected;
    string name;

    mixin TemplateCopy!Tpl;
  }

  @property
  {
    override string value() { return selected.join(","); }
    override void value(string v) { selected = v.split(","); }
  }

  @property
  {
    override string name() { return attributes["name"]; }
    override void name(string v) { attributes["name"] = v; }
  }

  uint min_options = 0;
  uint max_options = 0;
  SelectorOption[] options;
  string[] selected;
  
  this(HtmlForm _form, string _name)
  {
    super(_form, _name,"div");
    add_class("selector-widget");

  }

  override void copy(TextOutputStream output)
  {
    auto c = new SelectorTpl();
    c.options = options;
    c.selected = selected;
    c.name = name;
    
    content = c;

    form.doc.page_head.add_script("add_selector_widget('"~name~"','"~label~"','"~form.id~"',"~to!string(min_options)~","~to!string(max_options)~");", true);
    super.copy(output);
  }
}

string[] extract_selector_value(StrHash request, string name)
{
  if (!(name in request))
    return [];
  else
    return request(name);
}

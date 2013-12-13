
module jaypha.spinna.pagebuilder.widgets.sort;

public import jaypha.spinna.pagebuilder.widgets.widget;

import jaypha.html.entity;
import jaypha.container.hash;

import std.algorithm;
import std.array;

struct SortItem
{
  string label;
  string value;
}


class SortWidget : Widget
{
  SortItem[] sort_list;

  @property
  {
    override string value() { return null; }
    override void value(string v) {  }
  }

  @property
  {
    override string name() { return _n; }
    override void name(string v) { _n = v; }
  }

  this(HtmlForm _form, string _name)
  {
    super(_form, _name,"ul");
    add_class("sort-widget");
    _form.hiddens[_name] = "";
  }
  
  override void copy(TextOutputStream output)
  {
    form.doc.page_head.add_script("$('#"~id~"').sortable({update: function(e,u){ sort_update('"~id~"','"~name~"','"~form.id~"')}});", true);

    auto c = new Composite();
    foreach (item; sort_list)
      c.add("<li id='"~id~"-"~item.value~"'>"~encode_special(item.label)~"</li>");
    content = c;
    super.copy(output);
  }

  private:
    string _n;
}

string[] extract_sort_value(StrHash request, string name)
{
  if (!(name in request))
    return [];
  else
  {
    auto a = appender!(string[])();
    request[name].splitter(",").copy(a);
    return a.data;
  }
}

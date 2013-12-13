

module jaypha.spinna.pagebuilder.useful_stuff.dialog_box;

import jaypha.spinna.pagebuilder.htmlelement;

class DialogBox(string S) : HtmlElement
{
  Component header;

  class DialogTpl : Component
  {
    Component content;
    Component header;

    mixin TemplateCopy!S;
  }

  this(string _id)
  {
    super();
    add_class("jqmWindow");
    id = _id;
  }

  override void copy(TextOutputStream output)
  {
    auto c = new DialogTpl();
    
    if (content)
      c.content = content;
    c.header = header;
    content = c;
    super.copy(output);
  }
}


unittest
{
  import std.stdio;
  import std.array;

  auto x = new DialogBox!("dialog_default.tpl")("x");

    x.content = "hello";

  auto buf = appender!(char[])();

  x.copy(new TextOutputStream(output_range_stream(buf)));
  write(buf.data);
}

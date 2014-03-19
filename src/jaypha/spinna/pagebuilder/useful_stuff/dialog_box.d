

module jaypha.spinna.pagebuilder.useful_stuff.dialog_box;

import jaypha.spinna.pagebuilder.htmlelement;

class DialogBox(string S) : HtmlElement
{
  Component header;

  class DialogTpl : Component
  {
    Composite content;
    Component header;

    mixin TemplateCopy!S;
  }

  this(string _id)
  {
    super();
    add_class("jqmWindow");
    id = _id;
    tpl = new DialogTpl();
    tpl.content = new Composite();
    assert(!(tpl is null));
    super.add(tpl);
  }

  override Composite add(const(char)[] t) { tpl.content.add(t); return this; }
  override Composite add(Component o) { tpl.content.add(o); return this; }

  override void copy(TextOutputStream output)
  {
    tpl.header = header;
    super.copy(output);
  }

  private:
    DialogTpl tpl;
}


unittest
{
  //import std.stdio;
  import std.array;

  auto x = new DialogBox!("jaypha/spinna/pagebuilder/useful_stuff/dialog_default.tpl")("x");

  x.add("hello");

  auto buf = appender!(char[])();

  x.copy(new TextOutputStream(output_range_stream(buf)));
  assert(buf.data == "<div class='jqmWindow' id='x'>\n <div class='jqm-border-box'>\n  <div class='jqm-header'>\n    \n  </div>\n  <hr class='p'/>\n  <div class='dialog-content'>\n    hello\n  </div>\n  <div class='jqm-footer'>\n   <button class='dialog-ok-button' type='button'>OK</button>\n  </div>\n </div>\n\n<script type='text/javascript'>\n$(function()\n{\n  $('#x').jqm();\n  $('#x').jqmAddClose('#x .dialog-ok-button');\n  $('#about-btn').click(function(){ $('#about-dialog').jqmShow(); });\n});\n</script>\n\n</div>");
}

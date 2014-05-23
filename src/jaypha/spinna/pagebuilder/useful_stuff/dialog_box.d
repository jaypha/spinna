

module jaypha.spinna.pagebuilder.useful_stuff.dialog_box;

import jaypha.spinna.pagebuilder.htmlelement;
import jaypha.html.helpers;

class DialogBox(string S) : HtmlElement
{
  Component header, footer;

  class DialogTpl : Component
  {
    Composite content;
    Component header, footer;

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
    tpl.footer = footer;
    super.copy(output);
    output.print
    (
      javascript
      (
        "$(function(){$('#"~id~"').jqm();"
        "$('#"~id~"').jqmAddClose('#"~id~" .dialog-close-button');});"
      )
    );
  }

  private:
    DialogTpl tpl;
}


unittest
{
  import std.stdio;
  import std.array;

  auto x = new DialogBox!("jaypha/spinna/pagebuilder/useful_stuff/dialog_default.tpl")("x");

  x.add("hello");
  x.footer = new TextComponent("<button class='dialog-close-button' type='button'>OK</button>");

  auto buf = appender!(char[])();

  x.copy(new TextOutputStream(output_range_stream(buf)));
  writeln(buf.data);
  auto z = "<div class='jqmWindow' id='x'>\n <div class='jqm-border-box'>\n  <div class='jqm-header'>\n    \n  </div>\n  <hr class='p'/>\n  <div class='dialog-content'>\n    hello\n  </div>\n  \n   <div class='jqm-footer'>\n    <button class='dialog-close-button' type='button'>OK</button>\n   </div>\n  \n </div>\n</div><script type='text/javascript'>\n<!--\n$(function(){$('#x').jqm();$('#x').jqmAddClose('#x .dialog-close-button');});\n//-->\n</script>";
  assert(buf.data == z);
}

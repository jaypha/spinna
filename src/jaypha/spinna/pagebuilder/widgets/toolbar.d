module jaypha.spinna.pagebuilder.widgets.toolbar;

public import jaypha.spinna.pagebuilder.htmlelement;

class Toolbar : HtmlElement
{
  Toolbar add(HtmlElement o) { (cast(Composite) content).add(o); return this; }

  this()
  {
    super();
    add_class("toolbar");
    content = new Composite();
  }
}

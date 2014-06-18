module jaypha.spinna.pagebuilder.widgets.toolbar;

public import jaypha.spinna.pagebuilder.htmlelement;

class Toolbar : HtmlElement
{
  struct ComponentGroup
  {
    Component[] components;
    string label;
  }

  ComponentGroup[] groups;

  this()
  {
    super("table");
    add_class("toolbar");
    add(new DelegateComponent(&display));
  }

  void display(TextOutputStream output)
  {
    output.print("<tbody><tr class='widget-row'>");

    foreach (i,g; groups)
    {
      if (i != 0)
      {
        output.print("<td rowspan='2' class='gap1'><br/></td><td rowspan='2' class='gap2'><br/></td>");
      }
      foreach (c;g.components)
      {
        output.print("<td>");
        c.copy(output);
        output.print("</td>");
      }
    }
    output.print("</tr><tr>");

    foreach (i,g; groups)
    {
      if (g.label !is null)
        output.print("<td colspan='",g.components.length,"' class='toolbar-label'><hr/>",g.label,"</td>");
      else
        output.print("<td colspan='",g.components.length,"'> </td>");
    }
    output.print("</tr></tbody>");
  }
}

auto simple_toolbar()
{
  auto x = new HtmlElement();
  x.add_class("simple-toolbar");
  return x;
}

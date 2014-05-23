/*
 * Constructs a HTML <table> element.
 *
 * Copyright 2013 Jaypha
 *
 * Authors: Jason den Dulk
 */

module jaypha.spinna.pagebuilder.htmltable;

import jaypha.spinna.pagebuilder.htmlelement;

class HtmlTableRow : HtmlElement
{
  enum CellType : string { th = "th", td = "td" }

  this(CellType ct) { super("tr"); cell_type = ct; }

  HtmlElement cell()
  {
    auto c = new HtmlElement(cell_type);
    
    add(c);
    return c;
  }

  private:
    CellType cell_type;
}


class HtmlTable : HtmlElement
{
  string[] column_classes;

  this() { super("table"); t_body = new Composite(); }

  HtmlTableRow head_row()
  {
    if (!t_head) t_head = new Composite();
    auto c = new HtmlTableRow(HtmlTableRow.CellType.th);
    t_head.add(c);
    return c;
  }

  HtmlTableRow body_row()
  {
    auto c = new HtmlTableRow(HtmlTableRow.CellType.td);
    t_body.add(c);
    return c;
  }

  HtmlTableRow foot_row()
  {
    if (!t_foot) t_foot = new Composite();
    auto c = new HtmlTableRow(HtmlTableRow.CellType.td);
    t_foot.add(c);
    return c;
  }

  override void copy(TextOutputStream output)
  {
    foreach (c; column_classes)
      add("<col class='"~c~"'/>");
    if (t_head)
    {
      add("<thead>");
      add(t_head);
      add("</thead>");
    }
    add("<tbody>");
    add(t_body);
    add("</tbody>");
    if (t_foot)
    {
      add("<tfoot>");
      add(t_foot);
      add("</tfoot>");
    }
    super.copy(output);
  }

  private:
    Composite t_head, t_body, t_foot;
}

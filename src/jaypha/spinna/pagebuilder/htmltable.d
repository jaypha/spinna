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

  this(CellType ct) { super("tr"); cell_type = ct; cells = new Composite(); content = cells; }

  HtmlElement cell()
  {
    auto c = new HtmlElement(cell_type);
    
    cells.add(c);
    return c;
  }

  private:
    CellType cell_type;
    Composite cells;
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
    auto cn = new Composite();
    foreach (c; column_classes)
      cn.add("<col class='"~c~"'/>");
    if (t_head)
    {
      cn.add("<thead>");
      cn.add(t_head);
      cn.add("</thead>");
    }
    cn.add("<tbody>");
    cn.add(t_body);
    cn.add("</tbody>");
    if (t_foot)
    {
      cn.add("<tfoot>");
      cn.add(t_foot);
      cn.add("</tfoot>");
    }
    content = cn;
    super.copy(output);
  }

  private:
    Composite t_head, t_body, t_foot;
}

//Written in the D programming language
/*
 * Constructs a HTML <table> element.
 *
 * Copyright 2013 Jaypha
 *
 * Distributed under the Boost Software License, Version 1.0.
 * (See http://www.boost.org/LICENSE_1_0.txt)
 *
 * Authors: Jason den Dulk
 */

module jaypha.spinna.pagebuilder.htmltable;

import jaypha.spinna.pagebuilder.htmlelement;

class HtmlTableRow : HtmlElement
{
  enum CellType : string { th = "th", td = "td" }

  this(CellType ct) { super("tr"); cellType = ct; }

  HtmlElement cell()
  {
    auto c = new HtmlElement(cellType);
    
    super.put(c);
    return c;
  }

  override Composite put(string t) { auto c = cell(); c.add(new TextComponent!string(t)); return this; }
  override Composite put(wstring t) { auto c = cell(); c.put(new TextComponent!wstring(t)); return this; }
  override Composite put(dstring t) { auto c = cell(); c.add(new TextComponent!dstring(t)); return this; }
  override Composite put(Component o) { auto c = cell(); c.add(o); return this; }

  private:
    CellType cellType;
}


class HtmlTable : HtmlElement
{
  string[] columnClasses;

  this() { super("table"); tBody = new Composite(); }

  HtmlTableRow headRow()
  {
    if (!tHead) tHead = new Composite();
    auto c = new HtmlTableRow(HtmlTableRow.CellType.th);
    tHead.add(c);
    return c;
  }

  HtmlTableRow bodyRow()
  {
    auto c = new HtmlTableRow(HtmlTableRow.CellType.td);
    tBody.put(c);
    return c;
  }

  HtmlTableRow footRow()
  {
    if (!tFoot) tFoot = new Composite();
    auto c = new HtmlTableRow(HtmlTableRow.CellType.td);
    tFoot.put(c);
    return c;
  }

  override void copy(TextOutputStream output)
  {
    foreach (c; columnClasses)
      put("<col class='"~c~"'/>");
    if (tHead)
    {
      put("<thead>");
      put(tHead);
      put("</thead>");
    }
    put("<tbody>");
    put(tBody);
    put("</tbody>");
    if (tFoot)
    {
      put("<tfoot>");
      put(tFoot);
      put("</tfoot>");
    }
    super.copy(output);
  }

  private:
    Composite tHead, tBody, tFoot;
}

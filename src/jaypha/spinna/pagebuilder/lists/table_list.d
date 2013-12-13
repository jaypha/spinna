

module jaypha.spinna.pagebuilder.lists.table_list;

public import jaypha.spinna.pagebuilder.component;

import jaypha.spinna.pagebuilder.htmltable;
import jaypha.spinna.pagebuilder.lists.column;

//import std.traits;
import std.range;
import jaypha.types;

class TableList(R) : Component if (is (ElementType!R ==strstr))
{
  Column[] columns;

  HtmlTable table;
  string name;
  R source;

  this(R s) { table = new HtmlTable(); source = s; }

  override void copy(TextOutputStream output)
  {
    table.add_class("data");
    table.add_class("list");
    table.id = name~"-table";

    auto thr = table.head_row();
    foreach (i; 0..columns.length)
    {
      auto cell = thr.cell();
      cell.content = columns[i].header;
      table.column_classes ~= columns[i].name;
      if (i==0) cell.add_class("left");
      else if (i == columns.length-1) cell.add_class("right");
      else cell.add_class("middle");
    }

    ulong count = 0;
    foreach (row; source)
    {
      auto tbr = table.body_row();

      if (++count%2 == 0) tbr.add_class("even");
      else tbr.add_class("odd");

      foreach (i; 0..columns.length)
      {
        auto cell = tbr.cell();
        cell.content = columns[i].content(row);
        if (i==0) cell.add_class("left");
        else if (i == columns.length-1) cell.add_class("right");
        else cell.add_class("middle");
      }
    }

    table.copy(output);
  }
}

auto table_list(R)(R s) { return new TableList!R(s); }

unittest
{
  TableList!(string[string][]) tl;
}

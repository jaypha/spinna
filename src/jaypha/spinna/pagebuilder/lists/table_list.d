//Written in the D programming language
/*
 * Prints out a table of data based on a list given by a data source. Each row is displayed by the
 * template given.
 *
 * Copyhright 2013 Jaypha
 *
 * Distributed under the Boost Software License, Version 1.0.
 * (See http://www.boost.org/LICENSE_1_0.txt)
 *
 * Authors: Jason den Dulk
 */

/*
 * page number, num pages and page size are things relevant to the data source.
 * List Components do not need to know about them in order to work.
 */


module jaypha.spinna.pagebuilder.lists.table_list;

public import jaypha.spinna.pagebuilder.lists.list;

import jaypha.spinna.pagebuilder.htmltable;

import std.traits;
import std.range;
import jaypha.types;
import jaypha.algorithm;
import jaypha.datasource;

/+
deprecated class TableList : ListComponent
{
  HtmlTable table;
  string name;
  TableSource source;

  override void set_start(ulong start) { source.set_start(start); }
  override void set_limit(ulong limit) { source.set_start(limit); }
  override @property ulong size() { return source.size; }

  this(string _name, TableSource s) { name = _name; table = new HtmlTable(); source = s; }

  override void copy(TextOutputStream output)
  {
    table.add_class("data");
    table.add_class("list");
    table.id = name~"-table";

    auto thr = table.head_row();
    foreach (c; source.headers)
    {
      auto cell = thr.cell();
      cell.add(c);
    }

    source.reset();

    ulong count = 0;
    foreach (row; source)
    {
      auto tbr = table.body_row();

      if (++count%2 == 0) tbr.add_class("even");
      else tbr.add_class("odd");

      foreach (c; row)
      {
        auto cell = tbr.cell();
        cell.add(c);
      }
    }

    table.copy(output);
  }
}
+/
class TableListComponent(DS) : ListComponent if(isDataSource!(DS))
{
  alias ReturnType!(DS.apply) R;
  alias ElementType!R E;
  alias rtMap!(R, string[]) L;

  HtmlTable table;
  string id;
  DS source;
  string[] headers;
  string[] delegate(E) mapper;

  @property void start(ulong s) { _start = s; }
  @property void limit(ulong l) { _limit = s; }
  @property ulong length() { return source.length; }

  this
  (
    string _id,
    ref DS _source,
    string[] _headers,
    string[] delegate(E) _mapper
  )
  {
    id = _id;
    table = new HtmlTable();
    source = _source;
    headers = _headers;
    mapper = _mapper;
  }

  override void copy(TextOutputStream output)
  {
    table.add_class("data");
    table.add_class("list");
    table.id = id;

    auto thr = table.headRow();
    foreach (c; headers)
    {
      auto cell = thr.cell();
      cell.add(c);
    }

    auto list = L(source[_start.._start+_limit], mapper);

    ulong count = 0;
    foreach (row; list)
    {
      auto tbr = table.bodyRow();

      if (++count%2 == 0) tbr.addClass("even");
      else tbr.addClass("odd");

      foreach (c; row)
      {
        auto cell = tbr.cell();
        cell.add(c);
      }
    }

    table.copy(output);
  }

  private:
    ulong _start, _limit; 
}

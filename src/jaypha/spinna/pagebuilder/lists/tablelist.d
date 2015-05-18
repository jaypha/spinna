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


module jaypha.spinna.pagebuilder.lists.tablelist;

public import jaypha.spinna.pagebuilder.lists.list;

import jaypha.spinna.pagebuilder.htmltable;

import std.traits;
import std.range;
import jaypha.types;
import jaypha.algorithm;
import jaypha.datasource;

class TableListComponent(DS) : ListComponent if(isDataSource!(DS))
{
  alias DataSourceElementType!DS E;

  HtmlTable table;
  string id;
  DS source;
  string[] headers;
  string[] delegate(E) mapper;

  @property void start(size_t s) { _start = s; }
  @property void limit(size_t l) { _limit = l; }
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
    table.addClass("data");
    table.addClass("list");
    table.id = id;

    auto thr = table.headRow();
    foreach (c; headers)
    {
      auto cell = thr.cell();
      cell.add(c);
    }

    auto r = (_limit == 0)?source[_start..$]:source[_start..(_start+_limit)];
    auto list = rtMap!(typeof(r),string[])(r,mapper);

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
    size_t _start, _limit; 
}

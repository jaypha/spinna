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
 *
 * Written in the D programming language.
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

class TableList : ListComponent
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

unittest
{
  class MyTSource : TableSource
  {
    this(SourceType[] _data) { data = _data; }

    @property SourceType front() { return data[i+offset]; }
    @property bool empty() { return i>= psize || i+offset > data.length; }
    void popFront() { ++i; }

    void set_limit(ulong num) { psize = limit; }
    void set_start(ulong num) { offset = start; }

    @property SourceType headers() { return [ "label", "thwonk" ]; }

    void reset() { i = 0; }

    private:
      SourceType[] data;
      ulong i = 0;
      ulong psize = 0;
      ulong offset = 0;
      
  }


  auto output = new TextBuffer!string();

  auto ds = new MyTSource
  (
    [
      [ "hello", "honk" ],
      [ "beetle", "tonk" ],
      [ "tweetle", "tank" ],
      [ "twobird", "crank" ],
      [ "accost", "plank" ],
      [ "zigzag", "pluto" ],
      [ "mumbo", "jumbo" ]
    ]
  );

  auto sl = new TableList("tablelist", ds);

  ds.set_limit(2);
  ds.set_start(2);
  
  sl.copy(output);
  assert(output.data == "<table class='data list' id='tablelist-table'><thead><tr><th>label</th><th>thwonk</th></tr></thead><tbody><tr class='odd'><td>tweetle</td><td>tank</td></tr><tr class='even'><td>twobird</td><td>crank</td></tr></tbody></table>");
}

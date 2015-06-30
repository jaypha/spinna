//Written in the D programming language
/*
 * Prints out a list of items given by a data source. Each item is displayed
 * using a given ListItem component.
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


module jaypha.spinna.pagebuilder.lists.itemlist;

import jaypha.types;
public import jaypha.spinna.pagebuilder.lists.list;

import std.traits;
import std.range;
import jaypha.types;
import jaypha.algorithm;
import jaypha.datasource;


class ItemListComponent(DS) : ListComponent if(isDataSource!(DS))
{
  alias DataSourceElementType!DS E;

  DS source;
  string[string] delegate(E) mapper;

  @property void start(size_t s) { _start = s; }
  @property void limit(size_t l) { _limit = l; }
  @property ulong length() { return source.length; }

  ListItem listItem;

  this
  (
    ref DS _source,
    string[string] delegate(E) _mapper
  )
  {
    source = _source;
    mapper = _mapper;
  }

  override void copy(TextOutputStream output)
  {
    assert(listItem !is null);

    auto r = (_limit == 0)?source[_start..$]:source[_start..(_start+_limit)];
    auto list = rtMap!(typeof(r),strstr)(r,mapper);

    foreach (item; list)
    {
      listItem.set(item);
      listItem.copy(output);
    }
  }

  private:
    size_t _start, _limit;
}

alias ItemListComponent ItemList;

interface ListItem : Component
{
  void set(strstr);
}

class TemplateListItem(string tpl) : ListItem
{
  size_t count = 0;

  private strstr item;
  override void set(strstr data) { item = data; }
  
  override void copy(TextOutputStream output)
  {
    with (output)
    {
      mixin(TemplateOutput!tpl);
    }
    ++count;
  }

  @property string opDispatch(string s)() { assert(s in item,s~" not in item"); return item[s]; }
}

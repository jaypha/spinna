//Written in the D programming language
/*
 * Prints out a list of items given by a data source. Each item is displayed by the
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

depracated("Use itemList instead");
module jaypha.spinna.pagebuilder.lists.simple_list;

import jaypha.types;
public import jaypha.spinna.pagebuilder.lists.list;

import std.traits;
import std.range;
import jaypha.types;
import jaypha.algorithm;
import jaypha.datasource;


class SimpleList(DS,string tpl) : ListComponent if(isDataSource!(DS))
{
  alias DataSourceElementType!DS E;

  DS source;
  string[string] delegate(E) mapper;

  @property void start(ulong s) { _start = s; }
  @property void limit(ulong l) { _limit = l; }
  @property ulong length() { return source.length; }

  this
  (
    ref DS _source,
    string[string] delegate(E) _mapper
  )
  {
    source = _source;
    mapper = _mapper;
  }

  void copy(TextOutputStream output)
  {
    ulong count = 0;

    auto r = (_limit == 0)?source[_start..$]:source[_start..(_start+_limit)];
    auto list = rtMap!(typeof(r),strstr)(r,mapper);

    foreach (item; list)
    {
      with (output)
      {
        mixin(TemplateOutput!tpl);
      }
      ++count;
    }
  }

  private:
    ulong _start, _limit;
}

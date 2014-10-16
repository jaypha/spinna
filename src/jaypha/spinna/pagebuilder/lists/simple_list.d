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


module jaypha.spinna.pagebuilder.lists.simple_list;

import jaypha.types;
public import jaypha.spinna.pagebuilder.lists.list;
import jaypha.datasource;


class SimpleList(DS,string tpl) : ListComponent if(isDataSource!(DS))
{
  alias ReturnType!(DS.apply) R;
  alias ElementType!R E;
  alias rtMap!(R, string[string]) L;

  DS source;
  string[string] delegate(E) mapper;

  @property void start(ulong s) { _start = s; }
  @property void limit(ulong l) { _limit = s; }
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

    auto list = L(source[_start.._start+_limit], mapper);

    foreach (item; list)
    {
      mixin(TemplateOutput!tpl);
      ++count;
    }
  }

  private:
    ulong _start, _limit; 
}

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

/*
 * page number, num pages and page size are things relevant to the data source.
 * List Components do not need to know about them in order to work.
 */

module jaypha.spinna.pagebuilder.lists.simple_list;

import jaypha.types;
public import jaypha.spinna.pagebuilder.lists.list;

class SimpleList(string tpl) : ListComponent
{
  override void set_start(ulong start) { source.set_start(start); }
  override void set_limit(ulong limit) { source.set_start(limit); }

  ObjSource source;

  this(string _name, ObjSource _source)
  {
    source = _source;
  }

  void copy(TextOutputStream output)
  {
    source.reset();

    ulong count = 0;
    foreach (item; source)
    {
      mixin(TemplateOutput!tpl);
      ++count;
    }
  }
}

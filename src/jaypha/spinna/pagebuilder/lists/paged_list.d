/*
 * Component for paginator managed lists.
 *
 * Copyright 2013 Jaypha
 *
 * Distributed under the Boost Software License, Version 1.0.
 * (See http://www.boost.org/LICENSE_1_0.txt)
 *
 * Authors: Jason den Dulk
 *
 * Written in the D programming language.
 */

module jaypha.spinna.pagebuilder.lists.paged_list;
import jaypha.spinna.pagebuilder.lists.paginator;
import jaypha.spinna.pagebuilder.component;

import jaypha.spinna.pagebuilder.lists.list;

class PagedList
(
  string tpl = "jaypha/spinna/pagebuilder/lists/paged_default.tpl",
  string ptpl = "jaypha/spinna/pagebuilder/lists/paginator_default.tpl"
) : Component
{
  Paginator!ptpl paginator;
    
  string name;

  ListComponent content;

  this(string _name, string b, StrHash r)
  {
    name = _name;
    paginator = new Paginator!ptpl(name, b, r);
  }

  override void copy(TextOutputStream output)
  {
    if (paginator.display_all)
    {
      content.set_start(0);
      content.set_limit(0);
    }
    else
    {
      content.set_limit(paginator.page_size);
      content.set_start((paginator.page_number-1)*paginator.page_size);
    }

    paginator.num_pages = (content.size + paginator.page_size - 1)/paginator.page_size;

    mixin(TemplateOutput!tpl);
  }
}

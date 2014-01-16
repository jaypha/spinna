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

import jaypha.spinna.pagebuilder.lists.data_source;

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
    auto ds = content.data_source;

    if (paginator.display_all)
      ds.set_page_size(0);
    else
    {
      ds.set_page_size(paginator.page_size);
      ds.set_page(paginator.page_number);
    }
    paginator.num_pages = ds.num_pages;

    mixin(TemplateOutput!tpl);
  }
}

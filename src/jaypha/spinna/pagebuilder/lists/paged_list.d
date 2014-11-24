//Written in the D programming language
/*
 * Component for paginator managed lists.
 *
 * Copyright 2013 Jaypha
 *
 * Distributed under the Boost Software License, Version 1.0.
 * (See http://www.boost.org/LICENSE_1_0.txt)
 *
 * Authors: Jason den Dulk
 */

module jaypha.spinna.pagebuilder.lists.paged_list;
import jaypha.spinna.pagebuilder.lists.paginator;
import jaypha.spinna.pagebuilder.component;

import jaypha.spinna.pagebuilder.lists.list;

class PagedList(string tpl, string ptpl) : Component
{
  Paginator!ptpl paginator;
    
  string name;

  ListComponent content;

  this(string n, string b, StrHash r)
  {
    name = n;
    paginator = new Paginator!ptpl(name, b, r);
  }

  override void copy(TextOutputStream output)
  {
    if (paginator.displayAll)
    {
      content.start = 0;
      content.limit = 0;
    }
    else
    {
      content.limit = paginator.pageSize;
      content.start = (paginator.pageNumber-1)*paginator.pageSize;
    }

    paginator.numPages = (content.length + paginator.pageSize - 1)/paginator.pageSize;

    mixin(TemplateOutput!(tpl,"output.print"));
  }
}

auto defaultPagedList(string n, string b, StrHash r)
{
  return new PagedList!
  (
    "jaypha/spinna/pagebuilder/lists/paged_default.tpl",
    "jaypha/spinna/pagebuilder/lists/paginator_default.tpl"
  )
  (n, b, r);
}

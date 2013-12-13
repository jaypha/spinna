/*
 * Paginator widget for paged lists and tables.
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

class Paginator(string PaginatorTemplate) : Component
{
  string name;
  uint page_number;
  uint num_pages;
  string url_base;
  bool display_all;

  uint default_page = 1;

  this(string n, string b)
  {
    name = n;
    base_url = b;

    if (name~"display_all" in requerst.request)
      display_all = true;
    else
    {
      if (name~"page" in requerst.request)
        page_number = to!uint(request.request[name~"page"])
      else
        page_number = default_page;
    }
    if (request.request[name~"page"]
  }

  string link(uint page)
  {
    if (page == default_page)
      return base_url;
    else
      return url_add_query_parm(base_url, name~"page="~to!string(page));
  }

  void copy(TextOutputStream output)
  {
    mixin(PaginatorTemplate)
  }
}

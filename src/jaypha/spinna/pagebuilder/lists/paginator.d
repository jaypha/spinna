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

module jaypha.spinna.pagebuilder.lists.paginator;

import std.conv;

import jaypha.spinna.pagebuilder.component;
import jaypha.html.helpers;
import jaypha.url;
public import jaypha.container.hash;

import config.general;

class Paginator(string tpl = "jaypha/spinna/pagebuilder/lists/paginator_default.tpl") : Component
{
  string name;
  ulong num_pages;
  string url_base;

  @property
  {
    ulong page_number()
    {
      if (name~"-page" in request)
        return to!uint(request[name~"-page"]);
      else
        return default_page;
    }

    bool display_all() { return ((name~"-displayall" in request) !is null); }
    ulong page_size()
    {
      if (name~"-page-size" in request)
        return to!uint(request[name~"-page-size"]);
      else
        return default_page_size;
    }
  }

  ulong default_page = 1;
  ulong default_page_size = PAGE_SIZE_DEFAULT;

  this(string n, string b, ref StrHash r)
  {
    name = n;
    url_base = b;
    request = r;
  }

  string link(ulong page)
  {
    if (page == default_page)
      return url_base;
    else
      return url_add_query_parm(url_base, name~"-page",to!string(page));
  }

  mixin TemplateCopy!tpl;

  private:
    StrHash request;
}

auto new_paginator(string tpl = "jaypha/spinna/pagebuilder/lists/paginator_default.tpl")(string n, string b, ref StrHash r)
{
  return new Paginator!tpl(n,b,r);
}


unittest
{
  StrHash request;

  request["hello-page"] = "3";
  auto pg = new Paginator!()("hello", "abc.com", request);

  pg.num_pages = 12;

  auto output = new TextBuffer!string();

  assert(pg.page_size == PAGE_SIZE_DEFAULT);
  assert(!pg.display_all);
  assert(pg.page_number == 3);

  pg.copy(output);

  assert(output.data == "\n<table class='paginator paginator-hello'>\n <tbody>\n  <tr>\n   <td><a href='abc.com'>&lt;&lt;</a></td><td><a href='abc.com?hello-page=2'>&lt;</a></td><td><a href='abc.com'>1</a></td><td><a href='abc.com?hello-page=2'>2</a></td><td class='paginator-current'>3</td><td><a href='abc.com?hello-page=4'>4</a></td><td><a href='abc.com?hello-page=5'>5</a></td><td><a href='abc.com?hello-page=4'>&gt;</a></td><td><a href='abc.com?hello-page=12'>&gt;&gt;</a></td>\n  </tr>\n </tbody>\n</table>\n");
}
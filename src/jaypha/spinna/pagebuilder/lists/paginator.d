//Written in the D programming language
/*
 * Paginator widget for paged lists and tables.
 *
 * Copyright 2013 Jaypha
 *
 * Distributed under the Boost Software License, Version 1.0.
 * (See http://www.boost.org/LICENSE_1_0.txt)
 *
 * Authors: Jason den Dulk
 */

module jaypha.spinna.pagebuilder.lists.paginator;

import std.conv;

import jaypha.spinna.pagebuilder.component;
import jaypha.html.helpers;
import jaypha.url;
public import jaypha.container.hash;

import config.general;

//----------------------------------------------------------------------------

class Paginator(string tpl) : Component
{
  string name;
  ulong numPages;
  string urlBase;

  @property
  {
    //-----------------------------------------------------

    ulong pageNumber()
    {
      if (name~"-page" in request)
        return to!uint(request[name~"-page"]);
      else
        return defaultPage;
    }

    //-----------------------------------------------------

    bool displayAll() { return ((name~"-displayall" in request) !is null); }

    //-----------------------------------------------------

    ulong pageSize()
    {
      if (name~"-page-size" in request)
        return to!uint(request[name~"-page-size"]);
      else
        return defaultPageSize;
    }

    //-----------------------------------------------------
  }

  //-------------------------------------------------------

  ulong defaultPage = 1;
  ulong defaultPageSize = pageSizeDefault;

  //-------------------------------------------------------

  this(string n, string b, ref StrHash r)
  {
    name = n;
    urlBase = b;
    request = r;
  }

  //-------------------------------------------------------

  string link(ulong page)
  {
    if (page == defaultPage)
      return urlBase;
    else
      return addQueryParm(urlBase, name~"-page",to!string(page));
  }

  //-------------------------------------------------------

  mixin TemplateCopy!tpl;

  private:
    StrHash request;
}

//----------------------------------------------------------------------------

auto paginator(string tpl = "jaypha/spinna/pagebuilder/lists/paginatordefault.tpl")(string n, string b, ref StrHash r)
{
  return new Paginator!tpl(n,b,r);
}

//----------------------------------------------------------------------------

unittest
{
  import std.array;
  StrHash request;

  request["hello-page"] = "3";
  auto pg = paginator("hello", "abc.com", request);

  pg.numPages = 12;

  auto buf = appender!string();
  auto output = textOutputStream(buf);

  assert(pg.pageSize == pageSizeDefault);
  assert(!pg.displayAll);
  assert(pg.pageNumber == 3);

  pg.copy(output);

  assert(buf.data == "\n<table class='paginator paginator-hello'>\n <tbody>\n  <tr>\n   <td><a href='abc.com'>&lt;&lt;</a></td><td><a href='abc.com?hello-page=2'>&lt;</a></td><td><a href='abc.com'>1</a></td><td><a href='abc.com?hello-page=2'>2</a></td><td class='paginator-current'>3</td><td><a href='abc.com?hello-page=4'>4</a></td><td><a href='abc.com?hello-page=5'>5</a></td><td><a href='abc.com?hello-page=4'>&gt;</a></td><td><a href='abc.com?hello-page=12'>&gt;&gt;</a></td>\n  </tr>\n </tbody>\n</table>\n");
}
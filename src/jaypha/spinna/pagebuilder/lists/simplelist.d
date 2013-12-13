/*
 * Prints out a list of items given by an input range data source. Each item is drawn by the
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
 * List does not need to know about them in order to work.
 */

class SimpleList(string ItemTemplate) : HtmlElement
{
  this(string _name)
  {
    super();
    id=_name~"-list";
    name=_name;
  }

  void copy(TextOutputStrem output)
  {
    $dataSource->Reset();

    foreach (count,item; ds)
    {
      mixin(ItemTemplate);
      $o = new FWSObject();
    }
  }
}

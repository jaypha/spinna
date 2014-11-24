//Written in the D programming language
/*
 * Widget for list sorting.
 *
 * Copyright 2013 Jaypha
 *
 * Distributed under the Boost Software License, Version 1.0.
 * (See http://www.boost.org/LICENSE_1_0.txt)
 *
 * Authors: Jason den Dulk
 */

module jaypha.spinna.pagebuilder.widgets.sort;

public import jaypha.spinna.pagebuilder.widgets.widget;
public import jaypha.spinna.pagebuilder.widgets.enumerated;

import jaypha.html.entity;
import jaypha.html.helpers;
import jaypha.container.hash;

import std.algorithm;
import std.array;

class SortWidget : Widget
{
  EnumeratedOption[] options;

  @property
  {
    override string value() { return null; }
    override void value(string v) {  }
  }

  @property
  {
    override string name() { return _n; }
    override void name(string v) { _n = v; }
  }

  this(HtmlForm _form, string _name)
  {
    super(_form, _name, null, true,"ul");
    addClass("sort-widget");
    _form.hiddens[_name] = "";
  }
  
  override void copy(TextOutputStream output)
  {
    foreach (item; options)
      add("<li id='"~id~"-"~item.value~"'>"~encodeSpecial(item.label)~"</li>");

    super.copy(output);
    output.print(startUpJavascript("$('#"~id~"').sortable({update: function(e,u){ sortUpdate('"~id~"','"~name~"','"~form.id~"')}});"));
  }

  private:
    string _n;
}

string[] extractSortValue(StrHash request, string name)
{
  if (!(name in request))
    return [];
  else
  {
    auto a = appender!(string[])();
    request[name].splitter(",").copy(a);
    return a.data;
  }
}

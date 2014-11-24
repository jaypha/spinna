//Written in the D programming language
/*
 * Toolbar.
 *
 * Copyright (C) 2014 Jaypha.
 *
 * Distributed under the Boost Software License, Version 1.0.
 * (See http://www.boost.org/LICENSE_1_0.txt)
 *
 * Authors: Jason den Dulk
 */

module jaypha.spinna.pagebuilder.widgets.toolbar;

public import jaypha.spinna.pagebuilder.htmlelement;

/*
 * An ordinary toolbar to house a group of widgets in a row.
 * Nothing but an element for now, but may be expanded in the future.
 */

class Toolbar : HtmlElement
{
  this() { super(); addClass("toolbar"); }
}

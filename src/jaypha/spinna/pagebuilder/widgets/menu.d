//Written in the D programming language
/*
 * Menus.
 *
 * Copyright 2013 Jaypha.
 *
 * Distributed under the Boost Software License, Version 1.0.
 * (See http://www.boost.org/LICENSE_1_0.txt)
 *
 * Authors: Jason den Dulk
 */

module jaypha.spinna.pagebuilder.widgets.menu;
import jaypha.spinna.pagebuilder.component;

struct MenuItem
{
  enum LinkType { Link, Script, Label, Separator };
  string label;
  string link;
  LinkType type;
  MenuItem[] sub_menu;
}

class MenuComponent(string S = "jaypha/spinna/pagebuilder/widgets/menudefault.tpl") : Component
{
  MenuItem[] menu;

  this(MenuItem[] m) { menu = m; }

  mixin TemplateCopy!S;
}

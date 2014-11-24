//Written in the D programming language
/*
 * Icons that can be disabled, enabled or highlighted.
 *
 * Copyright (C) 2014 Jaypha.
 *
 * Distributed under the Boost Software License, Version 1.0.
 * (See http://www.boost.org/LICENSE_1_0.txt)
 *
 * Authors: Jason den Dulk
 */

module jaypha.spinna.pagebuilder.widgets.icon;

import config.general;

import jaypha.spinna.pagebuilder.htmlelement;

import std.conv;

/*
 * Icon class requires iconFileDir to be defined in config.general.
 */
 
static assert(__traits(compiles, iconFileDir));

/*
 * Icon class is designed to work with images that have three variants.
 * A "normal", "disabled" and "hot" (highlight) variants.
 * The images are accessed as <prefix>/<name>/<size>/<variant>.<suffix>
 * suffix defaults to "png".
 *
 * Size can be important in certian circumstances, so it must be supplied
 * separately.
 */

class Icon : HtmlElement
{
  string suffix = "png";
  string dir = iconFileDir;
  string name;
  ulong size;

  bool enabled = true;

  this(string n, ulong s)
  {
    super("img");
    addClass("icon");
    name = n;
    size = s;
  }

  override void copy(TextOutputStream output)
  {
    this.attributes["src"] = dir ~ "/" ~ name ~ "/" ~ to!string(size) ~ "/" ~(enabled?"normal":"disabled")~"."~suffix;
    super.copy(output);
  }
}

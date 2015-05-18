//Written in the D programming language
/*
 * A more sophisticated toolbar.
 *
 * Copyright (C) 2014 Jaypha.
 *
 * Distributed under the Boost Software License, Version 1.0.
 * (See http://www.boost.org/LICENSE_1_0.txt)
 *
 * Authors: Jason den Dulk
 */

module jaypha.spinna.pagebuilder.widgets.toolbarex;

public import jaypha.spinna.pagebuilder.htmlelement;

import std.array;

/*
 * Designed to be able to have two rows, one for the tools, and one for the
 * labels.
 * Can also be divided into groups.
 */

class ToolbarEx : HtmlElement
{
  struct ComponentGroup
  {
    Component[] components;
    string label;
  }

  ComponentGroup[] groups;

  this()
  {
    super("table");
    addClass("toolbar-ex");
    add(new DelegateComponent(&display));
  }

  void display(TextOutputStream output)
  {
    output.print("<tbody><tr class='widget-row'>");

    bool hasLabels = false;

    foreach (i,g; groups)
    {
      if (i != 0)
      {
        output.print("<td rowspan='2' class='gap1'><br/></td><td rowspan='2' class='gap2'><br/></td>");
      }
      foreach (c;g.components)
      {
        output.print("<td>");
        c.copy(output);
        output.print("</td>");
      }
      if (!g.label.empty)
        hasLabels = true;
    }
    output.print("</tr><tr>");

    if (hasLabels)
    {
      output.print("<tr>");
      foreach (i,g; groups)
      {
        if (!g.label.empty)
          output.print("<td colspan='",g.components.length,"' class='toolbar-label'><hr/>",g.label,"</td>");
        else
          output.print("<td colspan='",g.components.length,"'>&nbsp;</td>");
      }
      output.print("</tr>");
    }
    output.print("</tbody>");
  }
}

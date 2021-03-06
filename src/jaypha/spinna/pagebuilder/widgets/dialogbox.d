//Written in the D programming language
/*
 * Dialog boxes
 *
 * Copyright (C) 2014, Jaypha
 *
 * Distributed under the Boost Software License, Version 1.0.
 * (See http://www.boost.org/LICENSE_1_0.txt)
 *
 * Authors: Jason den Dulk
 */

module jaypha.spinna.pagebuilder.widgets.dialogbox;

import jaypha.spinna.pagebuilder.htmlelement;
import jaypha.html.helpers;

class DialogBox(string S) : HtmlElement
{
  Component header, footer;

  class DialogTpl : Component
  {
    Composite content;
    Component header, footer;

    mixin TemplateCopy!S;
  }

  bool openOnLoad;

  this(string _id)
  {
    super();
    addClass("jqmWindow");
    id = _id;
    tpl = new DialogTpl();
    tpl.content = new Composite();
    assert(!(tpl is null));
    super.add(tpl);
  }

  override Composite put(string t) { tpl.content.put(t); return this; }
  override Composite put(wstring t) { tpl.content.put(t); return this; }
  override Composite put(dstring t) { tpl.content.put(t); return this; }
  override Composite put(Component o) { tpl.content.put(o); return this; }

  override void copy(TextOutputStream output)
  {
    tpl.header = header;
    tpl.footer = footer;
    super.copy(output);
    output.print
    (
      javascript
      (
        "$(function(){$('#"~id~"').jqm();"
        "$('#"~id~"').jqmAddClose('#"~id~" .dialog-close-button');" ~
        (openOnLoad?"$('#"~id~"').jqmShow();":"")~"});"
      )
    );
  }

  private:
    DialogTpl tpl;
}

/*
 * Form Element for HTML.
 *
 * Copyright (C) 2014, Jaypha
 *
 * Distributed under the Boost Software License, Version 1.0.
 * (See http://www.boost.org/LICENSE_1_0.txt)
 *
 * Authors: Jason den Dulk
 *
 * Written in the D language.
 */

module jaypha.spinna.pagebuilder.htmlform;

import jaypha.spinna.pagebuilder.htmlelement;
import jaypha.spinna.pagebuilder.document;

import jaypha.types;
import jaypha.html.helpers;
import jaypha.algorithm;

import std.array;

class HtmlForm : HtmlElement
{
  strstr hiddens;
  Document doc;

  strstr values;
  
  this(Document d, string _id, string action = null)
  {
    super("form");
    assert(_id !is null, "Trying to create a form with no ID");
    id = _id;
    doc = d;
    if (action !is null) attributes["action"] = action;
    attributes["method"] = "post";
    hiddens["formid"] = id;
    add("<div class='form-wrapper'>");
  }
  
  override void copy(TextOutputStream output)
  {
    add("</div>");
    add(meld!(hidden)(hiddens).join());

    super.copy(output);

    // We delete the form session at this point on the basis that, if a person
    // reloads the form, they probably want to cleanse it.

    //if (Global.session.has("forms"~id));
    //  Global.session.remove("forms"~id);
  }
}

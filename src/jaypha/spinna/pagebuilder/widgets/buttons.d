/*
 * Button widgets.
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


module jaypha.spinna.pagebuilder.widgets.buttons;

public import jaypha.spinna.pagebuilder.htmlelement;


class SubmitButton : HtmlElement
{
  this(string name, string value, string label)
  {
    // $value is not used at present.
    super("input");
    add_class("button-widget");
    attributes["type"] = "submit";
    attributes["value"] = label;
    attributes["name"] = name;
  }
  
  @property warning(string w)
  {
    attributes["onclick"] = "return confirm('"~w~"')";
  }
}

class LinkButton : HtmlElement
{
  this(string link, string label)
  {
    super("button");
    add_class("button-widget");
    add(label);
    attributes["type"] = "button";
    attributes["onclick"] =  "document.location='"~link~"'";
    //attributes["href"] = link;
  }

  @property warning(string w)
  {
    auto x = attributes["onclick"];
    attributes["onclick"] = "var i = confirm('"~w~"'); if (i)  { "~x~"; }";
    //attributes["onclick"] = "return confirm('"~w~"')";
  }
}

string button_link(string link, string label)
{
  return "<a class='button-widget' href='"~link~"'>"~label~"</a>";
}


class OpenButton : HtmlElement
{
  this(string link, string label)
  {
    super("button");
    add_class("button-widget");
    add(label);
    attributes["type"] = "button";
    attributes["onclick"] = "window.open('"~link~"'); return false;";
  }

  @property warning(string w)
  {
    auto x = attributes["onclick"];
    attributes["onclick"] = "var i = confirm('"~w~"'); if (i)  { "~x~"; }";
    //attributes["onclick"] = "return confirm('"~w~"')";
  }
}

class JSButton : HtmlElement
{
  this(string script, string label)
  {
    super("button");
    add_class("button-widget");
    add(label);
    attributes["type"] = "button";
    attributes["onclick"] = script;
  }
}

class ResetButton : HtmlElement
{
  this(string label = "Reset")
  {
    super("input");
    add_class("button-widget");
    attributes["value"] = label;
    attributes["type"] = "reset";
  }
}

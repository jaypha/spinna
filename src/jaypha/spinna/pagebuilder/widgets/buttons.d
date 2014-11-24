//Written in the D programming language
/*
 * Button widgets.
 *
 * Copyright 2013 Jaypha
 *
 * Distributed under the Boost Software License, Version 1.0.
 * (See http://www.boost.org/LICENSE_1_0.txt)
 *
 * Authors: Jason den Dulk
 */


module jaypha.spinna.pagebuilder.widgets.buttons;

public import jaypha.spinna.pagebuilder.htmlelement;


class SubmitButton : HtmlElement
{
  this(string name, string value, string label)
  {
    // value is not used at present.
    super("input");
    addClass("button-widget");
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
    addClass("button-widget");
    add(label);
    attributes["type"] = "button";
    attributes["onclick"] =  "document.location='"~link~"'";
  }

  @property warning(string w)
  {
    auto x = attributes["onclick"];
    attributes["onclick"] = "var i = confirm('"~w~"'); if (i)  { "~x~"; }";
  }
}

string buttonLink(string link, string label)
{
  return "<a class='button-widget' href='"~link~"'>"~label~"</a>";
}


class OpenButton : HtmlElement
{
  this(string link, string label)
  {
    super("button");
    addClass("button-widget");
    add(label);
    attributes["type"] = "button";
    attributes["onclick"] = "window.open('"~link~"'); return false;";
  }

  @property warning(string w)
  {
    auto x = attributes["onclick"];
    attributes["onclick"] = "var i = confirm('"~w~"'); if (i)  { "~x~"; }";
  }
}

class JSButton : HtmlElement
{
  this(string script, string label)
  {
    super("button");
    addClass("button-widget");
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
    addClass("button-widget");
    attributes["value"] = label;
    attributes["type"] = "reset";
  }
}

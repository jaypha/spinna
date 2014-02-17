

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
    content = label;
    attributes["type"] = "button";

    attributes["onclick"] =  "document.location='"~link~"'";
  }

  @property warning(string w)
  {
    auto x = attributes["onclick"];
    attributes["onclick"] = "var i = confirm('"~w~"'); if (i)  { "~x~"; }";
    //attributes["onclick"] = "return confirm('"~w~"')";
  }
}

template link_button(string link, string label)
{
  enum link_button = "<button class='button-widget' type='button' onclick='document.location=\""~link~"\"'>"~label~"</button>";
}

class OpenButton : HtmlElement
{
  this(string link, string label)
  {
    super("button");
    add_class("button-widget");
    content = label;
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
    content = label;
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

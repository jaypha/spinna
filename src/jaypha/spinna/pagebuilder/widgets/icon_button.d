
module jaypha.spinna.pagebuilder.widgets.icon_button;

public import jaypha.spinna.pagebuilder.htmlelement;

import config.general;

class IconLinkButton : HtmlElement
{
  string label;
  string image;
  string size = "32";

  private string state;

  this (string _label, string _image, string link = null)
  {
    super("a");
    if (link is null)
      tag_name = "span";
    else
      attributes["href"] = link;
    add_class("icon-button");
    add_class("icon-link");
    disabled = false;
    add(new DelegateComponent(&display));
    label = _label;
    image = _image;
  }

  @property disabled(bool disable)
  {
    if (disable)
    {
      add_class("disabled");
      remove_class("hotable");
      state = "disabled";
    }
    else
    {
      remove_class("disabled");
      add_class("hotable");
      state = "normal";
    }
  }

  void display(TextOutputStream output)
  {
    output.print("<img src='",icon_file_dir,size,"/",state,"/",image,".png'/>",label);
  }
}
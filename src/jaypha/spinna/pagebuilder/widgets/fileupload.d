//Written in the D programming language
/*
 * Widget for file uploads.
 *
 * Copyright 2013 Jaypha
 *
 * Distributed under the Boost Software License, Version 1.0.
 * (See http://www.boost.org/LICENSE_1_0.txt)
 *
 * Authors: Jason den Dulk
 */

module jaypha.spinna.pagebuilder.widgets.fileupload;

public import jaypha.spinna.pagebuilder.widgets.widget;

import jaypha.html.helpers;
import std.conv;

class FileUploadWidget : Widget
{
  @property
  {
    override string value() { return null; }
    override void value(string v) {}
  }

  @property
  {
    override string name() { return attributes["name"]; }
    override void name(string v) { attributes["name"] = v; }
  }

  this
  (
    HtmlForm _form,
    string _name,
    string _label,
    bool _required
  )
  {
    super(_form, _name, _label, _required, "input");
    addClass("file-widget");
    attributes["type"] = "file";
    _form.attributes["enctype"] = "multipart/form-data";
  }

  override void copy(TextOutputStream output)
  {
    super.copy(output);
    output.print(javascript("new StringWidget($('#"~id~"'), {label: '"~label~"', required: "~to!string(required)~"});"));
  }
}

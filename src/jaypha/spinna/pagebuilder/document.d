/*
 * Document Element for HTML.
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

module jaypha.spinna.pagebuilder.document;

import jaypha.types;

public import jaypha.spinna.pagebuilder.component;
import jaypha.spinna.pagebuilder.htmlform;
public import jaypha.spinna.pagebuilder.htmlhead;
public import jaypha.spinna.pagebuilder.htmlelement;

public import jaypha.spinna.global;

import std.array;
import std.conv;

//-----------------------------------------------------------------------------

/*
 * Document is used to generate an HTML document.
 *
 * Correct XHTML requires an XML declaration, but stupid IE interperets this
 * as quirks mode, so we make it optional.
 */

class Document
{
  HtmlForm current_form;

  HtmlHead page_head;
  HtmlElement page_body;

  alias page_head docHead;
  alias page_body docBody;
  alias current_form currentForm;

  bool print_xml_decl = false;

  this(string page_id = null, string[] classes = null)
  {
    page_head = new HtmlHead();
    page_body = new HtmlElement("body");
    if (!page_id.empty)
      page_body.id = page_id;
    if (!classes.empty)
      page_body.css_classes = classes;
  }

  void copy(S,R)(R output)
  {
    auto body_buffer = new TextBuffer!S();
    auto head_buffer = new TextBuffer!S();

    page_body.copy(body_buffer);
    page_head.copy(head_buffer);

    if (print_xml_decl)
      output.put("<?xml version='1.0' encoding='"~utfEnc!S~"'?>");
    output.put(`<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">`);
    output.put("\r\n<html xmlns='http://www.w3.org/1999/xhtml' xml:lang='en' lang='en'>\r\n");
    output.put(head_buffer.data);
    output.put(body_buffer.data);
    output.put("\r\n</html>");
  }
}


void transfer(S = string)(Document doc, ref HttpResponse response, bool no_cache = true)
{
  auto b = appender!S();
  doc.copy!(S,typeof(b))(b);

  if (no_cache)
    response.no_cache();
  response.content_type("text/html; charset="~utfEnc!S);
  response.header("Content-Length", to!string(b.data.length));
  response.entity = cast(ByteArray)b.data;
}

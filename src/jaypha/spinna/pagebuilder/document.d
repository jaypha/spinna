//Written in the D programming language
/*
 * Document Element for HTML.
 *
 * Copyright (C) 2014, Jaypha
 *
 * Distributed under the Boost Software License, Version 1.0.
 * (See http://www.boost.org/LICENSE_1_0.txt)
 *
 * Authors: Jason den Dulk
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
  HtmlForm currentForm;

  HtmlHead docHead;
  HtmlElement docBody;

  alias docHead page_head;
  alias docBody page_body;
  alias currentForm current_form;

  bool printXmlDecl = false;

  this(string pageIid = null, string[] classes = null)
  {
    docHead = new HtmlHead();
    docBody = new HtmlElement("body");
    if (!pageId.empty)
      pageBody.id = pageId;
    if (!classes.empty)
      pageBody.cssClasses = classes;
  }

  void copy(S,R)(R output) if (isSomeString!S && isOutputRange!(R,S))
  {
    auto bodyBuffer = Appender!S();
    auto headBuffer = Appender!S();
    
    auto stream = textOutputStream(bodyBuffer);
    docBody.copy(stream);

    stream = textOutputStream(headBuffer);
    docHead.copy(stream);
    

    if (printXmlDecl)
      output.put("<?xml version='1.0' encoding='"~utfEnc!S~"'?>");
    output.put(`<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">`);
    output.put("\r\n<html xmlns='http://www.w3.org/1999/xhtml' xml:lang='en' lang='en'>\r\n");
    output.put(headBuffer.data);
    output.put(bodyBuffer.data);
    output.put("\r\n</html>");
  }
}


void transfer(S = string)(Document doc, ref HttpResponse response, bool noCache = true)
{
  auto b = appender!S();
  doc.copy!(S,typeof(b))(b);

  if (no_cache)
    response.noCache();
  response.content_type("text/html; charset="~utfEnc!S);
  response.header("Content-Length", to!S(b.data.length));
  response.entity = cast(ByteArray)b.data;
}

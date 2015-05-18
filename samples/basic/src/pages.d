// Written in the D programming language.
/*
 * Defines code for various pages for a sample website.
 *
 * Copyright 2014 Jaypha
 *
 * Distributed under the Boost Software License, Version 1.0.
 * (See http://www.boost.org/LICENSE_1_0.txt)
 *
 * Authors: Jason den Dulk
 */

module pages;

import jaypha.spinna.pagebuilder.document;
import jaypha.spinna.global;

import jaypha.spinna.json;
import std.array;

//---------------------------------------------------------------------------
// Construct a response directly

void getHome()
{
  response.entity ~= cast(ByteArray)"This page constructed directly.\n\n";
  response.entity ~= cast(ByteArray)"Hello World!\n";
}

//---------------------------------------------------------------------------
// Construct a response using the HTML document builder.

void getHtml()
{
  auto doc = new Document("home-page");
  doc.comment = "Main Comment";

  doc.docHead.title = "Page Title";

  doc.docHead.addCssFile("style.css");

  doc.docBody.addClass("special");
  doc.docBody.put("<h1>This page constructed using the HTML Document Builder.</h1>");

  auto hw = new HtmlElement("p");
  hw.cssStyles["color"] = "red";
  hw.put("Hello World!");
  doc.docBody.put(hw);

  doc.copy(response);
}

//---------------------------------------------------------------------------
// Construct a response using the JSON document builder.

void getJson()
{
  auto ret = JSONValue
    (
      [
        "success" : JSONValue(true),
        "message" : JSONValue("This page constructed using the JSON Document Builder"),
        "hello_world" : JSONValue("Hello World!")
      ]
    );

  ret.copy(response);
}

//---------------------------------------------------------------------------
// Construct a response using a template and TextOutputStream.

void getTemplate()
{
  auto buffer = appender!string();

  uint num = 1;

  auto stream = textOutputStream(buffer);
  stream.println("This page constructed ","with templates and TextOutputStream");
  stream.printfln("num = %d!",num);

  // These two are accessed from within the template
  string title = "Template Output";
  string message  = "Hello World";

  with (stream)
  {
    mixin(TemplateOutput!("template.tpl"));
  }

  response.entity ~= cast(ByteArray)buffer.data;
}

//---------------------------------------------------------------------------
// Construct a response using a template and PageBuilder

void getTemplate2()
{
  auto doc = new Document("template-page");

  doc.docBody.put("<h1>This page constructed using the HTML Document Builder and templates.</h1>");

  // These two are accessed from within the template
  string title = "Page Builder Template";
  string message  = "Hello Universe";

  auto pre = new HtmlElement("pre");

  mixin TemplateComponent!("template.tpl") CreatePage;

  doc.docBody.put(pre);
  pre.put(new CreatePage.TC());

  doc.copy(response);
}

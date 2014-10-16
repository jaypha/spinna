//Written in the D programming language
/*
 * Head Element for HTML.
 *
 * Copyright (C) 2014, Jaypha
 *
 * Distributed under the Boost Software License, Version 1.0.
 * (See http://www.boost.org/LICENSE_1_0.txt)
 *
 * Authors: Jason den Dulk
 */

module jaypha.spinna.pagebuilder.htmlhead;

import jaypha.spinna.pagebuilder.component;
import jaypha.types;
import jaypha.html.entity;
import jaypha.io.print;


import std.array;
import std.algorithm;

import config.general;

class HtmlHead : Composite
{
  struct MetaTag
  {
    string content;
    string name;
    string httpEquiv;
    string scheme;
    string lang;
    string dir;

    void copy(TextOutputStream output)
    {
      output.print("<meta content='",content,"'");
      if (name.length)
        output.print(" name='",name,"'");
      if (http_equiv.length)
        output.print(" http-equiv='",httpEquiv,"'");
      if (scheme.length)
        output.print(" scheme='",scheme,"'");
      if (lang.length)
        output.print(" lang='",lang,"'");
      if (dir.length)
        output.print(" dir='",dir,"'");
      output.println(">");
    }
  }

  bool useJquery = false;

  MetaTag[] metaTags;

  string title;         // The web page title.
  string description;   // Short description of the web page.
  string[] keywords;

  string comment;       // Primary comment.

  string[] scriptFiles; // Scripts that are stored in external files.
  string[] cssFiles;    // Stylesheet files.
  string[] cssText;    // Styles to be printed in the page

  void addScriptFile(string file)
  {
    if (!canFind(scriptFiles,file))
      scriptFiles ~= file;
  }

  void addCssFile(string file)
  {
    if (!canFind(cssFiles,file))
      cssFiles ~= file;
  }

  void setScript(string name, string text, bool onload = false)
  {
    if (onload) namedOnloadScripts[name] = text;
    else namedScripts[name] = text;
  }

  void addScript(string text, bool onload = false)
  {
    if (onload) ordinaryOnloadScripts ~= text;
    else ordinaryScripts ~= text;
  }

  void addSeo(strstr data)
  {
    if ("meta_keywords" in data)
      keywords ~= data["meta_keywords"];

    if ("meta_title" in data)
      title ~= " - " ~data["meta_title"];
    else if ("title" in data)
      title ~= " - " ~ data["title"];

    if ("meta_description" in data)
      description = data["meta_description"];
  }

  override void copy(TextOutputStream output)
  {
    output.println("<head>");
    output.println("<title>",title,"</title>");
    output.println("<meta content='text/javascript' http-equiv='content-script_type'/>");

    if (description.length)
    {
      output.println("<meta name='description' content=");
      output.println("'",encodeSpecial(description),"'");
      output.println("/>");
    }

    if (keywords.length)
    {
      output.println("<meta name='keywords' content='");
      output.println(keywords.map!encodeSpecial().join(" "));
      output.println("'/>");
    }

    foreach (mt; metaTags)
      mt.copy(output);

    foreach (f;css_files)
      output.println("<link rel='stylesheet' type='text/css' href='",f,"'/>");
    foreach (f;cssFiles)
      output.println("<link rel='stylesheet' type='text/css' href='",f,"'/>");

    if (css_text.length)
    {
      output.println("<style type='text/css'>\n<!--");
      foreach (f; css_text)
        output.println(f);
      output.println("-->\n</style>");
    }

    if (useJquery || namedOnloadScripts.length || ordinaryOnloadScripts.length)
      output.println("<script type='text/javascript' src='",jquery_src,"'></script>");
    foreach (f;script_files)
      output.println("<script type='text/javascript' src='",f,"'></script>");
    foreach (f;scriptFiles)
      output.println("<script type='text/javascript' src='",f,"'></script>");

    if (namedOnloadScripts.length || namedScripts.length ||
        ordinaryOnloadScripts.length || ordinaryScripts.length)
    {
      output.println("<script type='text/javascript'>");
      output.println("<!--");
      foreach (t;namedScripts)
        output.println(t);
      foreach (t;ordinaryScripts)
        output.println(t);

      if (namedOnloadScripts.length || ordinaryOnloadScripts.length)
      {
        output.println("$(function(){");
        foreach (t;namedOnloadScripts)
          output.println(t);
        foreach (t;ordinaryOnloadScripts)
          output.println(t);
        output.println("});");
      }

      output.println("\n//-->\n</script>");
    }

    super.copy(output);
    output.println("</head>");
  }

  private:
    strstr namedScripts;
    strstr namedOnloadScripts;
    string[] ordinaryScripts;
    string[] ordinaryOnloadScripts;

}


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
    string http_equiv;
    string scheme;
    string lang;
    string dir;
    
    string get_html()
    {
      auto app = appender!string();
      app.print("<meta content='",content,"'");
      if (name.length)
        app.print(" name='",name,"'");
      if (http_equiv.length)
        app.print(" http-equiv='",http_equiv,"'");
      if (scheme.length)
        app.print(" scheme='",scheme,"'");
      if (lang.length)
        app.print(" lang='",lang,"'");
      if (dir.length)
        app.print(" dir='",dir,"'");
      app.put(">");
      return app.data;
    }
  }

  bool use_jquery = false;

  MetaTag[] metatags;

  string title;         // The web page title.
  string description;   // Short description of the web page.
  string[] keywords;

  string comment;       // Primary comment.

  strstr script_files;   // Scripts that are stored in external files.
  strstr css_files;      // Stylesheet files.
  string[] css_text;     // Styles to be printed in the page

  void set_script(string name, string text, bool onload = false)
  {
    if (onload) named_onload_scripts[name] = text;
    else named_scripts[name] = text;
  }

  void add_script(string text, bool onload = false)
  {
    if (onload) ordinary_onload_scripts ~= text;
    else ordinary_scripts ~= text;
  }

  void add_seo(strstr data)
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
      output.println("'",encode_special(description),"'");
      output.println("/>");
    }

    if (keywords.length)
    {
      output.println("<meta name='keywords' content='");
      output.println(keywords.map!encode_special().join(" "));
      output.println("'/>");
    }

    foreach (f;css_files)
      output.println("<link rel='stylesheet' type='text/css' href='",f,"'/>");

    if (css_text.length)
    {
      output.println("<style type='text/css'>\n<!--");
      foreach (f; css_text)
        output.println(f);
      output.println("-->\n</style>");
    }

    if (use_jquery || named_onload_scripts.length || ordinary_onload_scripts.length)
      output.println("<script type='text/javascript' src='",jquery_src,"'></script>");
    foreach (f;script_files)
      output.println("<script type='text/javascript' src='",f,"'></script>");

    if (named_onload_scripts.length || named_scripts.length ||
        ordinary_onload_scripts.length || ordinary_scripts.length)
    {
      output.println("<script type='text/javascript'>");
      output.println("<!--");
      foreach (t;named_scripts)
        output.println(t);
      foreach (t;ordinary_scripts)
        output.println(t);

      if (named_onload_scripts.length || ordinary_onload_scripts.length)
      {
        output.println("$(function(){");
        foreach (t;named_onload_scripts)
          output.println(t);
        foreach (t;ordinary_onload_scripts)
          output.println(t);
        output.println("});");
      }

      output.println("\n//-->\n</script>");
    }

    super.copy(output);
    output.println("</head>");
  }

  private:
    strstr named_scripts;
    strstr named_onload_scripts;
    string[] ordinary_scripts;
    string[] ordinary_onload_scripts;

}

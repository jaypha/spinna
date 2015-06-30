//Written in the D programming language
/*
 * Router code generator.
 *
 * Copyright 2014-2015 Jaypha
 *
 * Distributed under the Boost Software License, Version 1.0.
 * (See http://www.boost.org/LICENSE_1_0.txt)
 *
 * Authors: Jason den Dulk
 */

module jaypha.spinna.router.builder;

import std.algorithm;
import std.container;
import std.range;
import std.conv;
import std.stdio;
import std.regex;
import std.getopt;
import std.exception;
import std.array;

import jaypha.container.stack;
import jaypha.container.queue;
import jaypha.container.set;

import jaypha.io.print;

alias Stack = jaypha.container.stack.Stack;

import yaml;

struct fndef
{
  string prefix;
  Queue!(string) commands;
}

//----------------------------------------------------------------------------
// The context associated with a node.

struct Context
{
  string pattern;
  string service;
  string nodePath;  // Node path is also cumulative.
  string docRoot;
  string method;
  string mdule;
  string[string] format;
}

//----------------------------------------------------------------------------
// Puts together code in a convenient output range.

struct Coder
{
  ref Coder opUnary(string s: "++")()
  {
    ++ident;
    return this;
  }

  ref Coder opUnary(string s: "--")()
  {
    --ident;
    return this;
  }

  void put(string stuff)
  {
    foreach(i;0..ident)
      code.put("  ");
    code.put(stuff);
  }

  @property string data() { return code.data; }

  private:
    Appender!string code;
    ulong ident;
}

//----------------------------------------------------------------------------


struct RouterBuilder
{
  string preamble;

  OrderedSet!string regexs;

  OrderedSet!string modules;
  OrderedSet!string stdModules;

  Coder code;

  Stack!Context contexts;

  this(string source)
  {
    contexts.put(Context
    (
      "",
      null,
      "",
      ".",
      null,
      "",
      Context.format.init
    ));

    Node root = Loader.fromString(source.dup).load();

    //--------------------------------

    if (root.containsKey("preamble"))
      preamble = root["preamble"].as!string;

    ++code;
    assert("routes" in root);
    processNode(root["routes"],"root");
    code.put("return ActionInfo(null);\n");
    --code;
  }

  //----------------------------------------------------------------------------
  // Processes a YAML node

  void processNode(Node node, string name)
  {
    auto context = createContext(node, name, contexts.front);

    if (node.containsKey("prefix"))
    {
      code.put(text("if (startsWith(path, \"",node["prefix"].as!string,"\"))\n")),
      code.put("{\n");
      ++code;
      code.put(text("path = path.chompPrefix(\"",node["prefix"].as!string,"\");\n")),
      stdModules.put("std.string");
    }

    contexts.put(context);

    foreach (string n, Node f; node)
    {
      switch (n)
      {
        case "serveFiles":
          processServeFiles(context, f.as!string);
          break;
        case "get":
        case "pet":
        case "delete":
        case "post":
          Context cntxt = context;
          cntxt.method = n;
          cntxt.service = f.as!string;
          if (cntxt.nodePath.length)
            cntxt.nodePath ~= ".";
          cntxt.nodePath ~= n;
          createService(cntxt);
          break;
        case "format":
          break;
        default:
          if (f.isMapping)
            processNode(f,n);
      }
  /*
      if (f.isMapping && n != "format")
        processNode(f,n);
      else
      {
        if (n == "get" || n == "put" || n == "delete" || n == "post")
        {
          Context cntxt = context;
          cntxt.method = n;
          cntxt.service = f.as!string;
          if (cntxt.nodePath.length)
            cntxt.nodePath ~= ".";
          cntxt.nodePath ~= n;
          createService(cntxt);
        }
      }
  */
    }
    contexts.popFront();

    if (context.service !is null)
    {
      // 'service' is a default.
      createService(context);
    }

    if (node.containsKey("prefix"))
    {
      code.put("return ActionInfo(null);\n");
      --code;
      code.put("}\n");
    }
  }

  //----------------------------------------------------------------------------
  // Creates code for a route mapping

  void createService(ref Context context)
  {
    if (canFind(context.pattern,'$'))
      createRegexService(context);
    else
      createStaticService(context);
  }

  //----------------------------------------------------------------------------

  void processServeFiles(ref Context context, string pattern)
  {
    modules.put("jaypha.spinna.filestreamer");
    stdModules.put("std.file");

    auto place = regexs.put(pattern);

    code.put
    (
      text
      (
        "mixin(matchFilePattern!(\"",context.docRoot,"\",\"rx",
        place,
        "\", ",
        (context.method is null?"null":"\"get\""),
        ", \"",
        context.nodePath~".files",
        "\"));\n"
      )
    );
  }

  //----------------------------------------------------------------------------

  void createStaticService(ref Context context)
  {
    stdModules.put("std.functional");

    modules.put(context.mdule);

    code.put
    (
      text
      (
        "mixin(matchStaticRoute!(\"",
        context.pattern,
        "\", ",
        (context.method is null?"null":"\""~context.method~"\""),
        ", \"",
        context.nodePath,
        "\", \"",
        context.mdule,'.',context.service,
        "\"));\n"
      )
    );
  }

  //----------------------------------------------------------------------------

  void createRegexService(ref Context context)
  {
    auto pattern = context.pattern;
    string[] params;
    modules.put(context.mdule);

    foreach(n,v; context.format)
    {
      params ~= n;
      auto r = regex(r"\$"~n);
      pattern = replace(pattern, r, "(?P<"~n~">"~v~")");
    }
    auto place = regexs.put(pattern);
    regexs.put(pattern);

    code.put
    (
      text
      (
        "mixin(matchRegexRoute!(\"rx",
        place,
        "\", ",
        (context.method is null?"null":"\""~context.method~"\""),
        ", \"",
        context.nodePath,
        "\", \"",
        context.mdule,'.',context.service,
        "\", \"",
        join(params, "\", \""),
        "\"));\n"
      )
    );
  }

  //----------------------------------------------------------------------------
  // Gets a copy of the previous contents, and overrides its values with any
  // information extracted from the node.

  Context createContext(Node node, string name, Context previous)
  {
    Context cntxt = previous;

    if (cntxt.nodePath.length)
      cntxt.nodePath ~= ".";
    cntxt.nodePath ~= name;
    if (node.containsKey("service"))
      cntxt.service = node["service"].as!string;
    if (node.containsKey("pattern"))
      cntxt.pattern = node["pattern"].as!string;
    if (node.containsKey("method"))
      cntxt.method = node["method"].as!string;
    if (node.containsKey("module"))
      cntxt.mdule = node["module"].as!string;
    if (node.containsKey("docroot"))
      cntxt.docRoot = node["docroot"].as!string;

    if (node.containsKey("format"))
    {
      cntxt.format = cntxt.format.init;
      foreach (string v,Node f; node["format"])
        cntxt.format[v] = f.as!string;
    }

    return cntxt;
  }


  //----------------------------------------------------------------------------

  string getCode()
  {
    auto writer = appender!string();
    writer.println("import jaypha.spinna.router.tools;");

    foreach (m; stdModules.range)
      writer.println("import ",m,";");
    writer.println("import std.exception;");
    writer.println();
    foreach (m; modules.range)
      writer.println("static import ",m,";");

    if (regexs.size() > 0)
    {
      int count = 0;
      writer.println();
      writer.println("import std.regex;");
      foreach (r;regexs.range)
        writer.println("enum rx",count++," = ctRegex!(`^",r,"$`);");
    }

    writer.println();
    writer.println("ActionInfo findRoute(string path, string method)\n{");

    writer.println();
    writer.print(code.data);
    /*
    foreach (n,f; fns)
    {
      writer.println();
      //writer.println("void delegate() find_",n,"(string path) {");
      writer.println("auto find_",n,"(string path) {");
      foreach (ss; f)
        writer.println("  ",ss);
      writer.println("  return ActionInfo(null,null);\n}");
    }
    */
    writer.println("}");
    return writer.data;
  }
}
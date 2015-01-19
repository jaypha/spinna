//Written in the D programming language
/*
 * Main program for constructing router code
 *
 * Copyright 2014 Jaypha
 *
 * Distributed under the Boost Software License, Version 1.0.
 * (See http://www.boost.org/LICENSE_1_0.txt)
 *
 * Authors: Jason den Dulk
 */

module makerouter;

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

alias Stack = jaypha.container.stack.Stack;

import yaml;

import Backtrace = backtrace.backtrace;

string preamble;
string roletype;
string authtype;
string errorPage = null;
string roleModule = null;

ulong[string] roles;

struct fndef
{
  string prefix;
  Queue!(string) commands;
}

struct Context
{
  string pattern;
  string service;
  string nodePath;  // Node path is also cumulative.
  string[] roles;
  string method;
  string redirect;
  string mdule;
  string[string] format;

  @property string rolesText()
  {
    string[] roleItems;
    foreach (r;roles)
      roleItems ~= "Role."~r;
    return roleItems.join("|");
  }
}

Stack!Context contexts;

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

Coder code;

OrderedSet!string regexs;

OrderedSet!string modules;

bool includeFunctional = false;
bool includeString = false;

//----------------------------------------------------------------------------

void printFormat(bool verbose = false)
{
  writeln("Format: makerouter [-h] [-d<output_dir>] <input_file>");
}

//----------------------------------------------------------------------------

Context contextDefault;

static this()
{
  contexts.put(Context
  (
    "",
    null,
    "",
    null,
    "get",
    null,
    "",
    Context.format.init
  ));
}

//----------------------------------------------------------------------------


void main(string[] args)
{
  string outputDir = ".";
  bool help = false;

  getopt
  (
    args,
    "d", &outputDir,
    "h", &help
  );

  if (help) { printFormat();  return; }

  Backtrace.install(stderr);

  //--------------------------------
  // Get YAML

  auto buffer = appender!(ubyte[])();

  auto chunker = stdin.byChunk(4096);
  chunker.copy(buffer);

  Node root = Loader.fromString(cast(char[])buffer.data).load();

  //--------------------------------


  //--------------------------------

  if (root.containsKey("preamble"))
    preamble = root["preamble"].as!string;

  if (root.containsKey("roleModule"))
    roleModule = root["roleModule"].as!string;

  if (root.containsKey("error"))
  {
    errorPage = root["error"].as!string;
    modules.put(errorPage.split(".")[0..$-1].join("."));
  }

  code.put("auto find_route(string path, string method)\n{\n");
  ++code;
  assert("routes" in root);
  processNode(root["routes"],"root");
  code.put("return ActionInfo(null);\n");
  --code;
  code.put("}\n");

  //--------------------------------

  auto f1 = File(outputDir~"/gen/router.d", "w");
  scope(exit) { f1.close(); }
  writeRouter(f1);

  auto f2 = File(outputDir~"/gen/permissions.d", "w");
  scope(exit) { f2.close(); }
  writePermissions(f2);
}

//----------------------------------------------------------------------------

void processNode(Node node, string name)
{
  auto context = createContext(node, name, contexts.front);
  if (context.service !is null)
  {
    // Having a service means we are defining a route.
    createService(context);
  }
  else
  {
    createSubRoute(node, context);
  }
}

//----------------------------------------------------------------------------

void createService(ref Context context)
{
  if (canFind(context.pattern,'$'))
    createRegexService(context);
  else
    createStaticService(context);
  extractPermissions(context);
}

//----------------------------------------------------------------------------

void createStaticService(ref Context context)
{
  includeFunctional = true;

  modules.put(context.mdule);

  code.put
  (
    text
    (
      "mixin(match_static_route!(\"",
      context.pattern,
      "\", \"",
      context.method,
      "\", \"",
      context.nodePath,
      "\", \"",
      context.mdule,'.',context.service,
      "\", \"",
      context.rolesText?context.rolesText:"0",
      "\", \"",
      context.redirect,
      "\"));\n"
    )
  );
}

//----------------------------------------------------------------------------

void createSubRoute(Node node, ref Context context)
{
  if (node.containsKey("prefix"))
  {
    code.put(text("if (startsWith(path, \"",node["prefix"].as!string,"\"))\n")),
    code.put("{\n");
    ++code;
    code.put(text("path = path.chompPrefix(\"",node["prefix"].as!string,"\");\n")),
    includeString = true;
  }

  contexts.put(context);

  foreach (string n, Node f; node)
  {
    if (f.isMapping)
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
  }
  contexts.popFront();

  if (node.containsKey("prefix"))
  {
    code.put("return ActionInfo(null);\n");
    --code;
    code.put("}\n");
  }
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
      "mixin(match_regex_route!(\"rx",
      place,
      "\",\"",
      context.method,
      "\", \"",
      context.nodePath,
      "\", \"",
      context.mdule,'.',context.service,
      "\", \"",
      context.rolesText?context.rolesText:"0",
      "\", \"",
      context.redirect,
      "\", \"",
      join(params, "\", \""),
      "\"));\n"
    )
  );
}

//----------------------------------------------------------------------------

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
  if (node.containsKey("roles"))
  {
    if (node["roles"].isScalar)
      cntxt.roles = [ node["roles"].as!string ];
    else
    {
      cntxt.roles = [];
      foreach (string v; node["roles"])
        cntxt.roles ~= v;
    }
  }
  if (node.containsKey("redirect"))
    if (node["redirect"].as!string != "false")
      cntxt.redirect = node["redirect"].as!string;
    else
      cntxt.redirect = null;
  if (node.containsKey("module"))
    cntxt.mdule = node["module"].as!string;

  if (node.containsKey("format"))
  {
    cntxt.format = cntxt.format.init;
    foreach (string v,Node f; node["format"])
      cntxt.format[v] = f.as!string;
  }

  return cntxt;
}


//----------------------------------------------------------------------------

string[string] allowedRoles;

void extractPermissions(ref Context context)
{
  if (context.roles.empty)
    return;

  allowedRoles[context.nodePath] = context.rolesText;
}

//----------------------------------------------------------------------------

void writeRouter(File writer)
{
  writer.writeln("/*\n * Detrmines which function to call based on the path\n *");
  if (preamble != "")
    writer.writeln(" * ",preamble.split("\n").join("\n * "));

  writer.writeln(" */");
  writer.writeln();
  writer.writeln("/*");
  writer.writeln(" * Generated file. Do not edit");
  writer.writeln(" */");
  writer.writeln();
  writer.writeln("module gen.router;");
  writer.writeln();
  writer.writeln("public import jaypha.spinna.router_tools;");
  if (includeFunctional)
    writer.writeln("import std.functional;");
  if (includeString)
    writer.writeln("import std.string;");
  writer.writeln("import std.exception;");
  if (roleModule !is null)
    writer.writeln("import "~roleModule~";");
  

  writer.writeln();
  foreach (m; modules.range)
    writer.writeln("static import ",m,";");

  if (errorPage !is null)
    writer.writeln("alias error_page ",errorPage,";");

  if (regexs.size() > 0)
  {
    int count = 0;
    writer.writeln();
    writer.writeln("import std.regex;");
    foreach (r;regexs.range)
      writer.writeln("enum rx",count++," = ctRegex!(`^",r,"$`);");
  }

  writer.writeln();
  writer.write(code.data);
  /*
  foreach (n,f; fns)
  {
    writer.writeln();
    //writer.writeln("void delegate() find_",n,"(string path) {");
    writer.writeln("auto find_",n,"(string path) {");
    foreach (ss; f)
      writer.writeln("  ",ss);
    writer.writeln("  return ActionInfo(null,null);\n}");
  }
  */
}

//----------------------------------------------------------------------------

void writePermissions(File writer)
{

  writer.writeln("/*\n * Info about authorisation for each action\n *");
  if (preamble != "")
    writer.writeln(" * ",preamble.split("\n").join("\n * "));

  writer.writeln(" */");
  writer.writeln();
  writer.writeln("/*");
  writer.writeln(" * Generated file. Do not edit");
  writer.writeln(" */");
  writer.writeln();
  writer.writeln("module gen.permissions;");
  writer.writeln();
  writer.writeln("import std.exception;");
  if (roleModule !is null)
    writer.writeln("public import "~roleModule~";");
  writer.writeln();
/+
  string[] rdef;
  foreach (s,v; roles)
    rdef ~= "  "~s~" = "~to!string(v);

  writer.writeln("enum Role : ulong\n{");
  writer.writeln(rdef.join(",\n"));
  writer.writeln("\n}");
  writer.writeln();
  writer.writeln("alias ulong RoleGroup;");
+/

  writer.writeln("immutable ulong[string] permissions;");
  if (allowedRoles.length)
  {
    writer.writeln();
    writer.writeln("shared static this()\n{\n  ulong[string] p = [");
    string[] permissionItems;
    foreach (n,p; allowedRoles)
      permissionItems ~= "    \""~n~"\": "~p;
    writer.writeln(permissionItems.join(",\n"));
    writer.writeln("  ];");
    writer.writeln("  permissions = assumeUnique(p);\n}");
  }
}

//----------------------------------------------------------------------------

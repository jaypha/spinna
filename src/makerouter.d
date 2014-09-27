/*
 * main program for constructing router code
 *
 * Copyright 2014 Jaypha
 *
 * Distributed under the Boost Software License, Version 1.0.
 * (See http://www.boost.org/LICENSE_1_0.txt)
 *
 * Authors: Jason den Dulk
 *
 * Written in the D programming language.
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

import dyaml.all;

import Backtrace = backtrace.backtrace;

string preamble;
string roletype;
string authtype;
string error_page = null;

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
  string node_path;  // Node path is also cumulative.
  ulong roles;
  string method;
  string redirect;
  string mdule;
  string[string] format;
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

set!string regexs;

set!string modules;

bool include_functional = false;
bool include_string = false;

//----------------------------------------------------------------------------

void print_format(bool verbose = false)
{
  writeln("Format: makerouter [-h] [-d<output_dir>] <input_file>");
}

//----------------------------------------------------------------------------

Context context_default;

static this()
{
  contexts.put(Context
  (
    "",
    null,
    "",
    0,
    "get",
    null,
    "",
    Context.format.init
  ));
}

//----------------------------------------------------------------------------


void main(string[] args)
{
  string output_dir = ".";
  bool help = false;

  getopt
  (
    args,
    "d", &output_dir,
    "h", &help
  );

  if (help) { print_format();  return; }

  Backtrace.install(stderr);

  //--------------------------------
  // Get YAML

  auto buffer = appender!(ubyte[])();

  auto chunker = stdin.byChunk(4096);
  chunker.copy(buffer);

  Node root = Loader.fromString(cast(string)buffer.data).load();

  //--------------------------------


  //--------------------------------

  if (root.containsKey("preamble"))
    preamble = root["preamble"].as!string;

  if (root.containsKey("roles"))
    define_roles(root["roles"]);

  if (root.containsKey("authtype"))
    authtype = root["authtype"].as!string;

  if (root.containsKey("error"))
  {
    error_page = root["error"].as!string;
    modules.put(error_page.split(".")[0..$-1].join("."));
  }

  code.put("auto find_route(string path, string method)\n{\n");
  ++code;
  process_node(root["routes"],"root");
  code.put("return ActionInfo(null);\n");
  --code;
  code.put("}\n");

  //--------------------------------

  //writeln(code.data);
  
  auto f1 = File(output_dir~"/gen/router.d", "w");
  scope(exit) { f1.close(); }
  write_router(f1);

  auto f2 = File(output_dir~"/gen/roles.d", "w");
  scope(exit) { f2.close(); }
  write_permissions(f2);

}

//----------------------------------------------------------------------------

void define_roles(Node node)
{
  foreach (string n, Node f; node)
  {
    assert(f.isScalar);
    roles[n] = f.as!ulong;
  }
}

void process_node(Node node, string name)
{
  auto context = create_context(node, name, contexts.front);
  if (context.service !is null)
  {
    // Having a service means we are defining a route.
    create_service(context);
  }
  else
  {
    create_sub_route(node, context);
  }
}

//----------------------------------------------------------------------------

void create_service(ref Context context)
{
  if (canFind(context.pattern,'$'))
    create_regex_service(context);
  else
    create_static_service(context);
  extract_permissions(context);
}

//----------------------------------------------------------------------------

void create_static_service(ref Context context)
{
  include_functional = true;

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
      context.node_path,
      "\", \"",
      context.mdule,'.',context.service,
      "\", \"",
      to!string(context.roles),
      "\", \"",
      context.redirect,
      "\"));\n"
    )
  );
}

//----------------------------------------------------------------------------

void create_sub_route(Node node, ref Context context)
{
  if (node.containsKey("prefix"))
  {
    code.put(text("if (startsWith(path, \"",node["prefix"].as!string,"\"))\n")),
    code.put("{\n");
    ++code;
    code.put(text("path = path.chompPrefix(\"",node["prefix"].as!string,"\");\n")),
    include_string = true;
  }

  contexts.put(context);

  foreach (string n, Node f; node)
  {
    if (f.isMapping)
      process_node(f,n);
    else
    {
      if (n == "get" || n == "put" || n == "delete" || n == "post")
      {
        Context cntxt = context;
        cntxt.method = n;
        cntxt.service = f.as!string;
        if (cntxt.node_path.length)
          cntxt.node_path ~= ".";
        cntxt.node_path ~= n;
        create_service(cntxt);
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

void create_regex_service(ref Context context)
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

  code.put
  (
    text
    (
      "mixin(match_regex_route!(\"rx",
      place,
      "\",\"",
      context.method,
      "\", \"",
      context.node_path,
      "\", \"",
      context.mdule,'.',context.service,
      "\", \"",
      to!string(context.roles),
      "\", \"",
      context.redirect,
      "\", \"",
      join(params, "\", \""),
      "\"));\n"
    )
  );
}

//----------------------------------------------------------------------------

Context create_context(Node node, string name, Context previous)
{
  Context cntxt = previous;

  if (cntxt.node_path.length)
    cntxt.node_path ~= ".";
  cntxt.node_path ~= name;
  if (node.containsKey("service"))
    cntxt.service = node["service"].as!string;
  if (node.containsKey("pattern"))
    cntxt.pattern = node["pattern"].as!string;
  if (node.containsKey("method"))
    cntxt.method = node["method"].as!string;
  if (node.containsKey("roles"))
  {
    if (node["roles"].isScalar)
      cntxt.roles = roles[node["roles"].as!string];
    else
    {
      cntxt.roles = 0;
      foreach (string v; node["roles"])
        cntxt.roles |= roles[v];
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

ulong[string] allowed_roles;

void extract_permissions(ref Context context)
{
  if (context.roles == 0)
    return;

  allowed_roles[context.node_path] = context.roles;
}

//----------------------------------------------------------------------------

void write_router(File writer)
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
  if (include_functional)
    writer.writeln("import std.functional;");
  if (include_string)
    writer.writeln("import std.string;");
  writer.writeln("import std.exception;");
  

  writer.writeln();
  foreach (m; modules.Range)
    writer.writeln("static import ",m,";");

  if (error_page !is null)
    writer.writeln("alias error_page ",error_page,";");

  if (regexs.size() > 0)
  {
    int count = 0;
    writer.writeln();
    writer.writeln("import std.regex;");
    foreach (r;regexs.Range)
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

void write_permissions(File writer)
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
  writer.writeln("module gen.roles;");
  writer.writeln();
  writer.writeln("import std.exception;");
  string[] rdef;
  foreach (s,v; roles)
    rdef ~= "  "~s~" = "~to!string(v);
  if (rdef.length)
  {
    writer.writeln("enum SpinnaRole : ulong\n{");
    writer.writeln(rdef.join(",\n"));
    writer.writeln("\n}");
    writer.writeln();
  }
  
  writer.writeln("immutable ulong[string] permissions;");
  if (allowed_roles.length)
  {
    writeln("shared static this()\n{\n  ulong[string] p = [");
    string[] permission_items;
    foreach (n,p; allowed_roles)
    {
      permission_items ~= "  \""~n~"\": "~to!string(p)~"uL";
    }
    writer.writeln(permission_items.join(",\n"));
    writer.writeln("];");
    writer.writeln("  permissions = assumeUnique(p);\n}");
  }
}

//----------------------------------------------------------------------------

struct Queue(T)
{
  alias Queue!T QT;

  private:

    T[] q;

  public:

    void put(T t)
    {
      q ~= t;
    }

    QT opOpAssign(string str)(T t) if (str == "~")
    {
      q ~= t;
      return this;
    }

    bool empty() { return q.empty; }
    T front() { return q.front(); }
    void popFront() { q.popFront(); }
}

//----------------------------------------------------------------------------

struct Stack(T)
{
  private:

    T[] q;

  public:

    void put(T t)
    {
      q ~= t;
    }

    bool empty() { return q.empty; }
    T front() { return q[$-1]; }
    void popFront() { q = q[0..$-1]; }
}

//----------------------------------------------------------------------------

struct set(T)
{
  private:

    T[] the_set;

  public:
    ulong put(T t)
    {
      foreach (i,e; the_set)
        if (t == e) return i;
      
      the_set ~= t;
      return the_set.length-1;
    }

    ulong size() { return the_set.length; }

    auto Range()
    {
      return the_set;
    }
}

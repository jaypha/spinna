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

import jaypha.fig.figparser;

enum module_name = "gen.router";

string preamble;
string error_page = null;

struct fndef
{
  string prefix;
  Queue!(string) commands;
}

Queue!(string)[string] fns;

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

  scope(success)
  {
    auto f1 = File(output_dir~"/router.d", "w");
    scope(exit) { f1.close(); }
    write_router(f1);

    auto f2 = File(output_dir~"/permissions.tpl", "w");
    scope(exit) { f2.close(); }
    write_permissions(f2);
    
  }

  fns["route"] = make!(Queue!(string));

  foreach (filename; args[1..$])
  {
    Figtree figs = read_fig_file(filename);

    if ("preamble" in figs)
      preamble = figs["preamble"].get_string();

    if ("error" in figs)
    {
      error_page = figs["error"].get_string();
      modules.put(error_page.split(".")[0..$-1].join("."));
    }

    if ("prefix" in figs)
    {
      fns["route"] ~=
        text
        (
          "if (!startsWith(path, \"",
          figs["prefix"].get_string(),
          "\")) return null;",
          "path = path.chompPrefix(\"",
          figs["prefix"].get_string(),
          "\");"
        );
    }

    create_sub_route("route",figs);
  }
}

//----------------------------------------------------------------------------

void create_node_route(string fn_name, Fig_Value node)
{
  auto members = node.get_list();
  auto pattern = members["pattern"].get_string();

  if (canFind(pattern,'$'))
    create_regex_node_route(fn_name, node);
  else
    create_static_node_route(fn_name, node);
}

//----------------------------------------------------------------------------

void create_static_node_route(string fn_name, Fig_Value node)
{
  include_functional = true;
  auto members = node.get_list();

  modules.put(members["module"].get_string());

  fns[fn_name] ~=

    text
    (
      "mixin(match_static_route!(\"",
      node.full_name,
      "\",\"",
      members["pattern"].get_string(),
      "\", \"",
      members["module"].get_string(),'.',members["service"].get_string(),
      "\"));"
    );
}

//----------------------------------------------------------------------------

void create_regex_node_route(string fn_name, Fig_Value node)
{
  auto members = node.get_list();

  Figtree formats = members["format"].get_list();
  string pattern = members["pattern"].get_string();
  string[] params;
  modules.put(members["module"].get_string());

  foreach(n,f; formats)
  {
    params ~= n;
    auto r = regex(r"\$"~n);
    pattern = replace(pattern, r, "(?P<"~n~">"~f.get_string()~")");
  }
  auto place = regexs.put(pattern);

  fns[fn_name] ~=
    text
    (
      "mixin(match_regex_route!(\"",
      node.full_name,
      "\",\"rx",
      place,
      "\", \"",
      members["module"].get_string(),'.',members["service"].get_string(),
      "\", \"",
      join(params, "\", \""),
      "\"));"
    );
}

//----------------------------------------------------------------------------

void create_sub_route(string fn_name, Figtree node)
{
  foreach (n,f; node)
  {
    if (f.type() != Fig_Type.List)
      continue;

    if ("prefix" in f.get_list())
    {
      include_string = true;

      fns[fn_name] ~=
      
        text
        (
          "mixin(match_sub_route!(\"",
          f.get_list()["prefix"].get_string(),
          "\", \"find_",
          fn_name ~ n,
          "\"));"
        );

      fns[fn_name ~ n] = make!(Queue!(string));

      create_sub_route(fn_name ~ n, f.get_list());
    }
    else if ("pattern" in f.get_list())
      create_node_route(fn_name, f);

    extract_permissions(f);
  }
}

//----------------------------------------------------------------------------

struct RoleInfo
{
  string[] roles;
  bool noredirect = false;
}

RoleInfo[string] allowed_roles;

void extract_permissions(Fig_Value node)
{
  RoleInfo info;

  auto list = node.get_list();

  if ("roles" !in list)
    return;

  auto roles = list["roles"];

  if (roles.type() == Fig_Type.Str)
  {
    info.roles = [ roles.get_string() ];
  }
  else if (roles.type() == Fig_Type.Array)
  {
    foreach (v; roles.get_array())
    {
      enforce(v.type() == Fig_Type.Str);
      info.roles ~= v.get_string();
    }
  }
  else
    throw new Exception("Node "~node.full_name~": roles must be valid string or list of strings");

  if ("noredirect" in list)
    info.noredirect = true;

  allowed_roles[node.full_name] = info;
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
  writer.writeln("module ",module_name,";");
  writer.writeln();
  writer.writeln("public import jaypha.spinna.router_tools;");
  if (include_functional)
    writer.writeln("import std.functional;");
  if (include_string)
    writer.writeln("import std.string;");

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

  foreach (n,f; fns)
  {
    writer.writeln();
    //writer.writeln("void delegate() find_",n,"(string path) {");
    writer.writeln("auto find_",n,"(string path) {");
    foreach (ss; f)
      writer.writeln("  ",ss);
    writer.writeln("  return ActionInfo(null,null);\n}");
  }
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
  writer.writeln("permissions = [");
  string[] permission_items;
  foreach (n,p; allowed_roles)
  {
    string item = "  \""~n~"\": Permission([";
    string[] role_items;
    foreach (r;p.roles)
      role_items ~= "AccountRole."~r;
    item ~= role_items.join(",");
    item ~= "],"~(p.noredirect?"true":"false")~")";
    permission_items ~= item;
  }
  writer.writeln(permission_items.join("\n,"));
  writer.writeln("];");
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

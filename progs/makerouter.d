module makerouter;

import std.algorithm;
import std.container;
import std.range;
import std.conv;
import std.stdio;
import std.regex;

import jaypha.fig.figparser;
import jaypha.io.print;


string module_name = "router";
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

/*
 * Synopsis makerouter <source>
 */

void main(string[] args)
{
  scope(success) { dump(stdout.lockingTextWriter); }

  Figtree figs = read_fig_file(args[1]);

  if ("module" in figs)
    module_name = figs["module"].get_string();

  if ("preamble" in figs)
    preamble = figs["preamble"].get_string();

  if ("error" in figs)
  {
    error_page = figs["error"].get_string();
    modules.put(error_page.split(".")[0..$-1].join("."));
  }

  fns["route"] = make!(Queue!(string));

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

void create_node_route(string fn_name, Figtree node)
{
  auto pattern = node["pattern"].get_string();

  if (canFind(pattern,'$'))
    create_regex_node_route(fn_name, node);
  else
    create_static_node_route(fn_name, node);
}

void create_static_node_route(string fn_name, Figtree node)
{
  include_functional = true;
  modules.put(node["module"].get_string());

  fns[fn_name] ~=

    text
    (
      "mixin(match_static_route!(\"path\",\"",
      node["pattern"].get_string(),
      "\", \"",
      node["module"].get_string(),'.',node["service"].get_string(),
      "\"));"

    );
}


void create_regex_node_route(string fn_name, Figtree node)
{
  Figtree formats = node["format"].get_list();
  string pattern = node["pattern"].get_string();
  string[] params;
  modules.put(node["module"].get_string());

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
      "mixin(match_regex_route!(\"path\",\"rx",
      place,
      "\", \"",
      node["module"].get_string(),'.',node["service"].get_string(),
      "\", \"",
      join(params, "\", \""),
      "\"));"
    );
}


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
          "mixin(match_sub_route!(\"path\",\"",
          f.get_list()["prefix"].get_string(),
          "\", \"find_",
          fn_name ~ n,
          "\"));"
        );

      fns[fn_name ~ n] = make!(Queue!(string));

      create_sub_route(fn_name ~ n, f.get_list());
    }
    else if ("pattern" in f.get_list())
      create_node_route(fn_name, f.get_list());
  }
}

void dump(Writer)(Writer w)
{
  w.println("/*\n * Detrmines which function to call based on the path\n *");
  if (preamble != "")
    w.println(" * ",preamble.split("\n").join("\n * "));

  w.println(" */");
  w.println();
  w.println("/*");
  w.println(" * Generated file. Do not edit");
  w.println(" */");
  w.println();
  w.println("module ",module_name,";");
  w.println();
  w.println("import jaypha.spinna.router_tools;");
  if (include_functional)
    w.println("import std.functional;");
  if (include_string)
    w.println("import std.string;");

  w.println();
  foreach (m; modules.Range)
    w.println("static import ",m,";");

  if (error_page !is null)
    w.println("alias error_page ",error_page,";");

  if (regexs.size() > 0)
  {
    int count = 0;
    w.println();
    w.println("import std.regex;");
    foreach (r;regexs.Range)
      w.println("enum rx",count++," ctRegex!(`^",r,"$`);");
  }

  foreach (n,f; fns)
  {
    w.println();
    w.println("void delegate() find_",n,"(string path) {");
    foreach (ss; f)
      w.println("  ",ss);
    w.println("  return null;\n}");
  }
}

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



module dbmake;

import std.getopt;
import std.stdio;

import jaypha.dbmake.dbdef;
import jaypha.dbmake.build;
import jaypha.dbmake.literal;

import jaypha.fig.value;
import jaypha.fig.diagnostic;
import jaypha.fig.figparser;
import jaypha.algorithm;
import std.exception;

void print_format(bool verbose = false)
{
  stderr.writeln("Format: dbgen [-d<dir>] [-f<filename>]");
  
  if (verbose)
  {
    stderr.writeln("  -f  Config file.");
    stderr.writeln("  -r  root dir for code output");
  }
}




void main(string[] args)
{
  string dir;
  string file_name;
  string module_name = "dbs";
  bool print_help = false;

  getopt
  (
    args,
    "d", &dir,
    "f", &file_name,
    "m", &module_name,
    "h", &print_help
  );

  if (print_help) { print_format(true); return; }
  if (file_name is null) { print_format(); return; }

  DatabaseDef db_def;

  Figtree figs = read_fig_file(file_name);
  
  foreach (n,v;figs)
  {
    enforce(v.is_list());
    if ("type" !in v.get_list())
    {
      db_def.tables[n] = TableDef(n);
      build_table_def(db_def.tables[n],v);
    }
    else
    {
      switch (v.get_list()["type"].get_string())
      {
        case "table":
          db_def.tables[n] = TableDef();
          db_def.tables[n].name = n;
          build_table_def(db_def.tables[n],v);
          break;

        case "view":
          break;
        case "function":
          break;
        default:
          break;
      }
    }
  }

  // Output code module to stdout.

  writeln("module dbs;");
  writeln("import jaypha.dbmake.dbdef;");
  writeln();
  writeln("DatabaseDef database_def;");
  writeln("static this() {");
  writeln("database_def = ");
  writeln(db_def.literal(),";");
  writeln("}");
}

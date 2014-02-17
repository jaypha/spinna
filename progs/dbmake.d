

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
  stderr.writeln("Format: dbmake [-m<module>] <source> ...");
  
  if (verbose)
  {
    stderr.writeln("  -m  Alternate module name.");
  }
}

void main(string[] args)
{
  string module_name = "dbs";
  bool print_help = false;

  getopt
  (
    args,
    "m", &module_name,
    "h", &print_help
  );

  if (print_help) { print_format(true); return; }
  if (args.length < 1) { print_format(); return; }

  DatabaseDef db_def;

  foreach (filename; args[1..$])
  {
    Figtree figs = read_fig_file(filename);

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
            db_def.functions[n] = FunctionDef();
            db_def.functions[n].name = n;
            build_function_def(db_def.functions[n], v);
            break;
          default:
            break;
        }
      }
    }
  }

  // Output code module to stdout.

  writeln("module "~module_name~";");
  writeln("import jaypha.dbmake.dbdef;");
  writeln();
  writeln("DatabaseDef database_def;");
  writeln("static this() {");
  writeln("database_def = ");
  writeln(db_def.literal(),";");
  writeln("}");
}

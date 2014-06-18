/*
 * main program for database table management
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

module makefixdb;

import std.getopt;
import std.stdio;

import jaypha.fixdb.dbdef;
import jaypha.fixdb.build;
import jaypha.fixdb.literal;

import jaypha.fig.value;
import jaypha.fig.diagnostic;
import jaypha.fig.figparser;
import jaypha.algorithm;
import std.exception;

//----------------------------------------------------------------------------
// Print out command line arguments.

void print_format(bool verbose = false)
{
  stderr.writeln("Format: makefixdb [-m<module>] <source> ...");
  
  if (verbose)
  {
    stderr.writeln("  -m  Alternate module name.");
  }
}

//----------------------------------------------------------------------------

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

  // Read each files, compile table definition structures.
  foreach (filename; args[1..$])
  {
    Figtree figs = read_fig_file(filename);

    foreach (n,v;figs)
    {
      enforce(v.is_list());
      if ("type" !in v.get_list())
      {
        auto table_def = TableDef();
        table_def.name = n;
        build_table_def(table_def,v);
        db_def.tables ~= table_def;
      }
      else
      {
        switch (v.get_list()["type"].get_string())
        {
          case "table":
            auto table_def = TableDef();
            table_def.name = n;
            build_table_def(table_def,v);
            db_def.tables ~= table_def;
            break;

          case "view":
            break;
          case "function":
            db_def.functions[n] = FunctionDef();
            //db_def.functions[n].name = n;
            build_function_def(db_def.functions[n], v);
            break;
          default:
            break;
        }
      }
    }
  }

  // Output structures as D code..

  writeln("module "~module_name~";");
  writeln("import jaypha.dbmake.dbdef;");
  writeln();
  writeln("DatabaseDef database_def;");
  writeln("static this() {");
  writeln("database_def = ");
  writeln(db_def.literal(),";");
  writeln("}");
}

//Written in the D programming language
/*
 * Constructs a router code file
 *
 * Copyright 2014 Jaypha
 *
 * Distributed under the Boost Software License, Version 1.0.
 * (See http://www.boost.org/LICENSE_1_0.txt)
 *
 * Authors: Jason den Dulk
 */

/*
 * The input is in YAML format and read from the input.
 * The output is D code and written to the output.
 */

module makerouter;

import jaypha.spinna.router.builder;

import std.stdio;
import std.getopt;
import std.array;
import std.algorithm;

import Backtrace = backtrace.backtrace;

//----------------------------------------------------------------------------

void printFormat(bool verbose = false)
{
  writeln("Format: makerouter [-h] [-m<module_name>]");
}

void main(string[] args)
{
  string moduleName = "gen.router";

  bool help = false;

  getopt
  (
    args,
    "m", &moduleName,
    "h", &help
  );

  if (help) { printFormat();  return; }

  Backtrace.install(stderr);

  //--------------------------------
  // Get YAML

  auto buffer = appender!(ubyte[])();

  auto chunker = stdin.byChunk(4096);
  chunker.copy(buffer);

  auto builder = RouterBuilder(cast(string)buffer.data);

  //Node root = Loader.fromString(cast(char[])buffer.data).load();

  //auto f1 = File(outputDir~"/gen/router.d", "w");
  //scope(exit) { f1.close(); }

  writeln("// Written in the D programming language");
  writeln("/*\n * Detrmines which function to call based on the path and method\n *");
  if (builder.preamble != "")
    writeln(" * ",builder.preamble.split("\n").join("\n * "));

  writeln(" */");
  writeln();
  writeln("/*");
  writeln(" * Generated file. Do not edit");
  writeln(" */");
  writeln();
  writeln("module ",moduleName,";");
  writeln();
  write(builder.getCode());
}

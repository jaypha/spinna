//Written in the D programming language
/*
 * Server adapter for console.
 *
 * Copyright 2014 Jaypha
 *
 * Distributed under the Boost Software License, Version 1.0.
 * (See http://www.boost.org/LICENSE_1_0.txt)
 *
 * Authors: Jason den Dulk
 */

//---------------------------------------------------------------------------
// consoleRequestProcessor
//---------------------------------------------------------------------------
// This module defines a RequestProcessor instance that uses the Spinna
// Router and interfaces with the console.
//---------------------------------------------------------------------------

module jaypha.spinna.main.console;

import jaypha.types;
public import jaypha.io.dirtyio;
import jaypha.spinna.process;

import std.stdio;
import std.range;
import std.array;
import std.string;

debug
{
  import Backtrace = backtrace.backtrace;
}

//---------------------------------------------------------------------------

alias RequestProcessor!(ReadIn,WriteOut)
  consoleRequestProcessor;

//---------------------------------------------------------------------------

void main(string[] args)
{
  strstr env;

  debug { Backtrace.install(stderr); }
  auto writer = WriteOut(stdout);
  auto errWriter = WriteOut(stderr);
  auto reader = ReadIn(stdin);

  consoleRequestProcessor.run
  (
    env,
    reader,
    writer,
    errWriter
  );
  writeln();
}
